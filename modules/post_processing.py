import pandas as pd
import math
from IPython import embed
import pickle
import datetime as dt
import traceback
import sys
import numpy as np
import perf_postprocessing
from pprint import pprint
# embed()


def post_processing(KIND_RESULTS, RESULTS, cores=1, dump_results=0):

    if dump_results:
        filename='/tmp/'+dt.datetime.now().strftime('%y%m%d-%H%M%S')+'.pickle'
        with open(filename, 'wb') as f:
            pickle.dump([KIND_RESULTS, RESULTS], f)
        print("RESULTS saved in", filename)

    try:
        time_df = pd.DataFrame.from_dict(KIND_RESULTS["time"], orient="index")
        for c in time_df.columns:
            d = time_df[c].dropna()
            # Sometimes we have a single number sometimes else a list.
            # Use this ugly method to mean the first layer and then use np to do the mean again
            # TODO: for some results we should do sum(mean)) and for some others sum(sum())...
            d_m = [dd if type(dd) is float else np.mean(dd) for dd in list(d)]
            RESULTS["AVGT-"+c] = np.mean(d_m)
            #d_s = [dd if type(dd) is float else np.sum(dd) for dd in list(d)]
            # RESULTS["TOTALT-"+c] = np.sum(d_s)

        #if "PERF" in KIND_RESULTS.keys():
        #    # if it is a list for the same time, keep only the first
        #    # Then discard first and last 1/4 of all the data
        #    for c in perf_df.columns:
        #        RESULTS["AVGT-"+c] = perf_df[c].mean()
        #        #d = perf_df[c].dropna().apply(
        #        #    lambda v: v[0] if type(v) is list else v)
        #        #start = math.ceil(len(d) * .25)
        #        #stop = math.floor(len(d) * .75)
        #        #RESULTS["AVG-"+c] = d[start:stop].mean()

        if "COUNT" in RESULTS.keys() and  "AVGT-CPU_LOAD" in RESULTS.keys():
                RESULTS["AVGT-CPU_LOAD_PERCORE"] = RESULTS["AVGT-CPU_LOAD"] / cores
                RESULTS["AVGT-LOAD_CYCLES_PERCORE"] = RESULTS["AVGT-LOAD_CYCLES"] / cores
                RESULTS["AVGT-LOAD_CYCLES_PP"] = RESULTS["AVGT-LOAD_CYCLES"] / \
                    RESULTS["COUNT"]

        if "AVG_LOAD" in time_df.columns and "RX" in time_df.columns:
                rx_load = time_df[["AVG_LOAD", "RX"]]
                rx_load = rx_load.dropna(thresh=1)
                rx_load = rx_load.query("AVG_LOAD != 0.0 and RX != 0.0")
                rx_load = rx_load.sort_index()
                rx_load["AVG_LOAD"] = rx_load.interpolate()["AVG_LOAD"]
                rx_load = rx_load.dropna()
                rx_load = rx_load.groupby("AVG_LOAD").mean()
                #rx_load = rx_load.set_index("AVG_LOAD")
                #rx_load = rx_load.sort_index()
                KIND_RESULTS["RX_LOAD"] = rx_load.to_dict("index")

        if all([res in RESULTS.keys() for res in ["INSERTS", "LOOKUPS"]]):
            RESULTS["LOOKUPS_INSERTS_RATIO"] = RESULTS["LOOKUPS"] / RESULTS["INSERTS"]
            RESULTS["INSERTS_LOOKUPS_RATIO"] = RESULTS["INSERTS"] / RESULTS["LOOKUPS"]
        if all([res in RESULTS.keys() for res in ["INSERTS", "FLOWS"]]):
            RESULTS["INSERTS_FLOWS_RATIO"] = RESULTS["INSERTS"] / RESULTS["FLOWS"]
            RESULTS["FLOWS_INSERTS_RATIO"] = RESULTS["FLOWS"] / RESULTS["INSERTS"]
        if all([res in RESULTS.keys() for res in ["RECYCLED", "INSERTS"]]):
            RESULTS["RECYCLED_INSERTS_RATIO"] = RESULTS["RECYCLED"] / RESULTS["INSERTS"]



    except Exception:
        exc_info = sys.exc_info()
        traceback.print_exception(*exc_info)
        message = ''.join(traceback.format_exception(*exc_info))
        #print(message)
        filename='/tmp/npf_error'+dt.datetime.now().strftime('%y%m%d-%H%M%S')+'.pickle'
        #message = ''.join(traceback.format_exception(None, exc_info, exc_info.__traceback__))
        with open(filename, 'wb') as f:
            pickle.dump([message, KIND_RESULTS, RESULTS], f)
        print("DEBUG RESULTS saved in", filename)
        #embed()
        del exc_info

if __name__ == "__main__":
    if len(sys.argv)<3:
        print("Usage: %s file.pickle stats.log", __name__)
        exit(1)

    fpickle = sys.argv[1]
    fperf = sys.argv[2]
    kr, r  = pickle.load(open(fpickle, "rb"))
    print("Pre processing")
    print(kr)
    print(r)
    print("PERF processing")
    perf_postprocessing.perf_postprocessing(fperf, kr, r)
    print("PERF RESULTS")
    pprint(kr["PERF"])
    print("Post Processed")
    post_processing(kr,r,1,False)
    print(kr)
    print(r)



