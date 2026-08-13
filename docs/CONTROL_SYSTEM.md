# Control System

The MSC speed PI commands machine q-current; the averaged 20 ms inner loop represents torque-current tracking. The GSC DC-voltage PI commands d-current and a zero reactive-current reference commands q-current. Both axes have PI current controllers with filter decoupling.

The synchronous-reference-frame PLL uses PCC q-voltage: `Delta omega = Kp*vq + xi`, `dot(xi)=Ki*vq`. Weak-grid impedance couples injected current into measured PCC phase. With the benchmark high PLL integral gain, this loop interacts with GSC current dynamics and produces the identified 4.84 Hz mode.

Mitigation is explicit PLL retuning from `Ki=2.8` to `Ki=0.5`; no plant, wind, SCR, disturbance time, solver or initial-grid condition changes. This is a technically direct intervention because PLL/grid interaction is the mode source in this reduced model. A separate SSDC was not implemented; adding one would complicate the controlled demonstration without being needed to meet the one-or-more mitigation requirement.
