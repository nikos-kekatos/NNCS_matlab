Switching Controller
---
Here is one of the "classical" papers on combining controllers ("Switching Between Stabilizing Controllers"). 
The paper nicely states that designing a single controller with multiple performance requirements (noise rejection, fast response) is hard
but it is possible with switching controller, but the switching law should satisfy some condition for stability to be preserved.

The system structure can be found below.

![](model_struct.png)

The transformed system structure is

![](model_struct_2.png)

The plant (process model) is

$H_P(s)=\frac{-1000}{s(s+0.875)(s+50)}$

Ideally, one would like to design a controller that is both fast and has good
measurement noise rejection properties. Clearly this is not possible, as increasing the bandwidth of the closed-loop system will also make the system more
sensitive to measurement noise. We opt then to design two distinct controllers:
Controller $K_1$ has low closed-loop bandwidth and is therefore not very sensitive to noise but exhibits a slow response. Controller $K_2$ has high bandwidth
and is therefore fast but very sensitive to noise.


Compute: closed-loop response of controllers K1, K2, and the switched multi-controller
to a square reference r. Large measurement noise n was injected into the system
in the interval $t \in [18, 40]$. The top plots show the output y and the bottom plots
the tracking error $e_T := r − y − n$. For the switched controller, $K_1$ was used in the
interval $t \in [22, 42]$ and $K_2$ in the remaining time.

The controller transfer functions are

$K_1\approx \frac{-6.694(s+0.9446)(s+50.01)}{(s^2+13.23*s+9.453^2)(s+50.05)}$

$K_2\approx \frac{-2.187^2(s+0.9977)(s+66.28)}{(s^2+467.2*s+486.2^2)(s+507)}$

The control transfer matrices
![](transfer_matrices.png).
