import re
import sys
import pandas as pd
from pprint import pprint

pattern = r"^\s*([.\d\.]+)\s*([\d\,]+)\s*(\S*)\s.*$"


def beautify(s):
    return s.replace(",","").replace("\r","").replace("\n","")

def parse_perf(perf_file):

    llc_loads={}
    llc_misses={}
    l1_loads={}
    l1_misses={}

    regexp = re.compile(pattern)
    with open(perf_file) as f:
        for _,row in enumerate(f):
            #row = beautify(row)
            m = regexp.match(row)
            if m != None:
                t = float(m.group(1))
                v = float(m.group(2).replace(",",""))
                k = m.group(3)
                if k == "L1-dcache-loads":
                    l1_loads[t] = v
                elif k == "L1-dcache-load-misses":
                    l1_misses[t] = v
                elif k == "LLC-loads":
                    llc_loads[t] = v
                elif k == "LLC-load-misses":
                    llc_misses[t] = v
    return (l1_loads, l1_misses, llc_loads, llc_misses) 

def perf_postprocessing(f, KIND_RESULTS, RESULTS):
    try:
        l1_l, l1_m, llc_l, llc_m = parse_perf(f)
        
        time_df = pd.DataFrame.from_dict(KIND_RESULTS["time"], orient="index")
        start_time = min(time_df.index)
        # By default discard first second
        start_count = start_time + 1

        if "FLOWS" in time_df.columns:
            start_count = min(time_df.query("FLOWS > 1").index)
        elif "RX" in time_df.columns:
            start_count = min(time_df.query("RX > 1e5").index)

        stop_count = max(time_df.index)
        print("Traffic stops at", stop_count)
        # cut at least 1 second or 10% at the end
        cut_stop_seconds = min((stop_count - start_count) *0.1, 1)
        stop_count-=cut_stop_seconds

        # print("PERF started at ", perf0)
        # print("There is traffic at ", start_count)
        # print("Will stop at ", stop_count)
        

        # Sync the perf results and cut 
        perf0 = RESULTS["PERF_START"]
        for l in l1_l, llc_l, l1_m, llc_m:
            l = { (k+perf0) : v for k,v in l.items() if start_count <= (k+perf0) <= stop_count }
        del RESULTS["PERF_START"]

        # print("The new values are:")
        # print("L1_LOADS", l1_l)
        # print("L1_MISS", l1_m)
        # print("LLC_LOADS", llc_l)
        # print("LLLC_MISS", llc_m)

        # TOTALS
        RESULTS["TOTAL-L1-LOADS"] = sum([v for k,v in l1_l.items()])
        RESULTS["TOTAL-LLC-LOADS"] = sum([v for k,v in llc_l.items()])
        RESULTS["TOTAL-L1-MISSES"] = sum([v for k,v in l1_m.items()])
        RESULTS["TOTAL-LLC-MISSES"] = sum([v for k,v in llc_m.items()])
        # RATIOS
        RESULTS["TOTAL-L1-RATIO"] = RESULTS["TOTAL-L1-MISSES"] / RESULTS["TOTAL-L1-LOADS"]
        RESULTS["TOTAL-LLC-RATIO"] = RESULTS["TOTAL-LLC-MISSES"] / RESULTS["TOTAL-LLC-LOADS"]

        # pprint({k:v for k,v in RESULTS.items() if "L" in k})

        # Per packet
        if "COUNT" in RESULTS.keys():
            count = RESULTS["COUNT"]
            if "TOTAL-L1-LOADS" in RESULTS.keys():
                RESULTS["L1-LOADS-PP"] = RESULTS["TOTAL-L1-LOADS"] / count
                RESULTS["LLC-LOADS-PP"] = RESULTS["TOTAL-LLC-LOADS"] / count
                RESULTS["L1-MISSES-PP"] = RESULTS["TOTAL-L1-MISSES"] / count
                RESULTS["LLC-MISSES-PP"] = RESULTS["TOTAL-LLC-MISSES"] / count


        # time statistics
        # TODO: sync with the real time

        # Generate the perf time-results: per each time, calculate miss ratios
        KIND_RESULTS["PERF"]= { k:
                {"L1_MISS_RATIO": l1_m[k] / l1_l[k], "LLC_MISS_RATIO": llc_m[k] / llc_l[k] }
                for k in l1_l.keys()}
    except Exception:
        exc_info = sys.exc_info()
        traceback.print_exception(*exc_info)
        message = ''.join(traceback.format_exception(*exc_info))
        #embed()
        del exc_info

if __name__ == "__main__":
    print(parse_perf(sys.argv[1]))
