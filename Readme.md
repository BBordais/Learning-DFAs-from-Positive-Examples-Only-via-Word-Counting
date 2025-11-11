# Learning-DFAs-from-Positive-Examples-Only-via-Word-Counting

## Installation

When installing Python packages, we advice the user to use 'pip install' in a virtual python environment, which can setup and shut down e.g. with the commands:
python3 -m venv venv
source venv/bin/activate
deactivate

Depending on the files to run, the packages to install are not the same:
  - To run the symbolic algorithm, one needs to install the corresponding Python 3 packages. See Symbolic/README.md and Symbolic/requirements.txt
  
  - To run the ILP algorithm, one needs Python 3 packages sys, random, time. Also, given the size of the model, you will need a Gurobi license 
  [https://www.gurobi.com/academia/academic-program-and-licenses/] to run the algorithm, any academic can get one for free. See 
  [https://support.gurobi.com/hc/en-us/articles/13232844297489-How-do-I-set-up-a-Web-License-Service-WLS-license] to set up the license. 
  The experiments conducted have been done with a WLS (Web License Service) license, which needs an internet connection upon usage. 
  
  - To run the heuristic algorithm computing a starting DFA, one needs the following c++ libraries:
	- libstdc++.so.6
	- libgcc_s.so.1
	- libc.so.6
	- libm.so.6
	
  - To run the summary programs Run_Exp/Summary.sh and Run_Exp/Score.sh, one needs the Python 3 library numpy

## How to run

Example:
``
# Symbolic algorithm
./Symbolic/infer specific DFA -f "path_to_traces" --dfa="path_to_saved_dfa" --dfa-starting="path_to_starting_dfa"  -n=n --method=SYMB

with:
  - path_to_traces : path to the file containing the (positive) traces, e.g. Traces/Traces01.words
  - path_to_saved_dfa : path where the computed dfa is stored, usually ends with .dot, e.g. dfa.dot. 
  The option --dfa may not be used.
  - path_to_starting_dfa : path where the a dfa is stored (as a .dot file), which will be used as a starting dfa. An error will occur if the starting dfa does accept all the positive words.
  The option --dfa-starting may not be used.
  - n : the number of states of the dfa. Typically, 1 <= n <= 10

# ILP encoding
python3 ILP/Main.py path_to_traces path_to_saved_dfa n h t

with:
  - path_to_traces : path to the file containing the (positive) traces, e.g. Traces/Traces01.words
  - path_to_saved_dfa : path where the computed dfa is stored, usually ends with .dot, e.g. dfa.dot. 
  - n : the number of states of the dfa. Typically, 1 <= n <= 10
  - h : the maximal word length considered (for counting purpose). Usually, h = 2n-2.
  - t : timeout (number of seconds) on the time for solving (does not count the time to build the model).

# Heuristic algorithm
In the folder Heuristic_Approximation, the executable file main can be used. Alternatively, one can recompile it, via:
make clean
make

Then, in the parent folder:
./Heuristic_Approximation/main path_to_traces path_to_saved_dfa n h InitRand NbRun

with:
  - path_to_traces : path to the file containing the (positive) traces, e.g. Traces/Traces01.words
  - path_to_saved_dfa : path where the computed dfa is stored, usually ends with .dot, e.g. dfa.dot. 
  - n : the number of states of the dfa. Typically, 1 <= n <= 10
  - h : the maximal word length considered (for counting purposes). Usually, h = 2n-2.
  - InitRand : number of attempts to initialize a transition system. Usuaully, InitRand = 100
  - NbRun : number of runs to find the DFA with the best score. Usually, NbRun = 50.
  
Once the heuristic algorithm is executed, one can call the symbolic algorithm using the option --dfa-starting with the location path_to_saved_dfa used in heuristic algorithm to store the computed dfa.

``

## Acknowledgments

As discussed below in the folder details, we use the code from [https://github.com/cryhot/samp2symb/tree/paper/posdata]

## Folder details 
``Heuristic_Approximation``
Contains all the c++ code of the heuristic algorithm. Note that it also contains the folder eigen-3.4.0 which is a c++ library used for matrix operations. 
This was used to compute the number of accepted words up to a given length.

``ILP``
Contains the python file Main.py which implements our ILP encoding in Gurobi. 

``Result``
Contains the results of all of our experiments. Each of the three folders Result_Heuristic_Approximation, Result_ILP, Result_Symbolic contains 28
folders each corresponding to the associated Traces file. Each of these folders contains itself three folders: Detailed Summary, which stores 
the outputs of the algorithms; DFAs, which stores the computed DFAs; and TimeSummary which stores files the times taken by all the computations.
In addition, the file Result/Summary.txt summarizes the times taken by all cumputations, and the file Result/CorelationCoefficients.txt stores 
the Pearson corelation coefficient for each heuristic computation.

``Run_Exp``
Contains the shell files used to run the different experiments, and gather all results. If one wants to run again experiments with those files, 
the variables (e.g. Traces file number), are not given as input but written directly in the file. Specifically:
  - runSymb.sh is used to run experiments on the Symbolic algorithm.
  - runILP.sh is used to run experiments on the ILP algorithm.
  - runHeuristic.sh is used to run experiments on the Heuristic+Symbolic algorithm.

Furthermore, the two other shell files are used to gather results about the experiments:
  - Summary.sh looks through all experiments (stored in the Result folder) and outputs a summary of every computation. The output of this 
  is currently stored in the file Result/Summary.txt
  - Score.sh looks at the experiments performed with the Heuristic+Symbolic algorithm: it writes in different files the score and runtime of each 
  test and file  on which the Heuristic+Symbolic algorithm was run (these data points are plotted in Figure 4 in the paper); it also outputs 
  the Pearson corelation coefficients (stored in the file Result/CorelationCoefficients.txt) for each file and the total 
  (they are depicted in Figure 5 in the paper).

``Symbolic``
Contains the code of the symbolic algorithm developped in the paper: [_Learning Interpretable Temporal Properties from Positive Examples Only_](https://ojs.aaai.org/index.php/AAAI/article/download/25800/25572)

The original code can be downloaded at: [https://github.com/cryhot/samp2symb/tree/paper/posdata]

We made a few little changes to the original project that we list below:
  - In the file Symbolic/Infer, we added Lines 142-145 which allow to specify a starting dfa from an input, along with Line 171.
  - In the file Symbolic/samp2symb/algo/infer_specific.py, we modified Lines 338, 366, 436, 458 because the aalpy.save() function did not work for us. 
  - In the file Symbolic/samp2symb/base/dfa.py, we added lines 850-886 that encode a python function that extracts a DFA from a .dot file. Such a
  function already existed, but did not seem to work on our experimentations.

``Traces``
Contains 28 trace files, from Traces01.words to Traces28.words. All these traces (i.e. words) come from the project [https://github.com/cryhot/samp2symb/tree/paper/posdata]



