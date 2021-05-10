# Experiment data for "High-speed Connection Tracking in Modern Servers"

This repository holds the code to run the experiments, the results and additional figures not published in the paper.

The tests are managed with [NPF](https://github.com/tbarbette/npf.git), which will download and compile Fastclick automatically.
However, manual compilation of our DPDK version with lazy deletion is required.

# How to use

- Get NPF from [GitHub](https://github.com/tbarbette/npf.git) and create _cluster_ files for your configuration.
   - You can also install it with pip:
	```
	python3 -m pip install --user npf
	```
- Get and compile [our DPDK version](https://github.com/conntrackHPSR21/dpdk). Follow the normal DPDK procedure.
- Update the scripts (mainly the `*.sh` and `*.repo` files) accordingly to your paths, user, machines names and NICs
- Run any of the `*.sh` files in this folders to run the experiments
- You can change the number of repetitions by setting the environmental variable `NRUNS`
- All the scripts accept additional arguments for `npf`.
    For example, to force re-compilation, while running a single test:
    ```
	NRUNS=1 ./single_thread.sh --force-build
    ```



