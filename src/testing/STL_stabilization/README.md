STL formula - Breach
===

In this folder, we have added the files to evaluate an STL stabilization formula with a step/input change.


- [Download](#Download)
- [Requirements](#Requirements)
- [Installation](#Installation)
- [Contents](#Contents)
- [Usage](#Usage)
- [Brief Explanation](#What is it about?)

Download
---

The files should be downloaded from the NNCS_Matlab Github repository via ssh or https.

Clone the repository via git as follows:

```git clone https://github.com/nikos-kekatos/NNCS_matlab.git```

Requirements
---

- Matlab
- Simulink
- Deep Learning Toolbox

No other toolbox is needed to run the script.

Installation
---

No special installation is needed. 

Contents
---
This folder contains the following files 

1. `STL_stabilization_property.m` (main function)
2. `specs_stabilization.stl` (text file used to define the STL formulas, the variable name is φ) 
3. `watertank_STL_test.slx` (Simulink model)


Usage
---

Simply navigate to the `src/testing/STL_stabilization` and run the file
``STL_stabilization_property.m`` from the command window or the button of the interface.

What is it about?
---

We start with a Simulink model and a specification and we create a Breach system. Then, we run GNN falsification to check if the property is satisfied or not.