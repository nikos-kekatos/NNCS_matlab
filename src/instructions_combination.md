Controller Combination with Neural Network
===

The motivation of this approach is to combine multiple nominal controllers intro a single neural network. The generated NN is expected to outperform each of the individual controllers and the individually generated NNs.


- [Requirements/Dependencies] (#Dependencies)
- [Installation](#Installation)
- [Files](#Files)
- [Usage](#Usage)
- [Development](#Development)

Requirements/Dependencies <a name="Dependencies"></a>
---

Running the accompanied files requires the installation of Matlab/Simulink. The [Deep Learning toolbox](https://www.mathworks.com/products/deep-learning.html) should also be installed. No other toolboxes or add-ons are required.

Installation <a name="Installation"></a>
---
No special installation is needed. The files should be simply downloaded. There are two options: (i) download the files directly from the [Github repository](https://github.com/nikos-kekatos/NNCS_matlab), or (ii) clone the repository via ssh or https. Note that the branch that contains the code for this part is called ``nikos_comb``.

Clone the repository via git as follows:

```
git clone https://github.com/nikos-kekatos/NNCS_matlab.git
git checkout nikos_comb 
```

If you have already downloaded the repository, you should run `git pull` first, i.e. `git pull origin nikos_comb`.

If you have not downloaded the repository and you are only interested in this work/branch, run

` git clone -b nikos_comb --single-branch  https://github.com/nikos-kekatos/NNCS_matlab.git
` 


Usage <a name="Usage"></a>
---

The main file is named `main_nncs_combination.m`. The steps/functions of this script are as follows.

Our starting point is two nominal controllers, C1, C2, and two properties (objectives), P1, P2.



Results
---
The 1st controller produces 17 cex out of 100 traces.

The 2nd controller produces 23 cex out of 100 traces.