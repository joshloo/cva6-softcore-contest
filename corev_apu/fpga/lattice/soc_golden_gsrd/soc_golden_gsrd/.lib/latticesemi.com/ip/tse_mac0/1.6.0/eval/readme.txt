####Constraining the IP
- Include eval/constraint.pdc in Post-synthesis Constraint Files before running STA
- The PHY/MAC core clocks (cdr clock and user clock) are constrained as asynchronous.
  - Heirarchy and wire names of these clocks might change (depending on the device and/or Radiant version), please update the .pdc file accordingly.
  - Check the generated_clocks to get the accurate clock path/name of these 2 clocks.