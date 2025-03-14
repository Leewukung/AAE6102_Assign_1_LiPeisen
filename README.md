# AAE6102 Satellite Communication and Navigation Assignment 1

**Course:** AAE6102 Satellite Communication and Navigation  
**Institution:** The Hong Kong Polytechnic University, Department of Aeronautical and Aviation Engineering  
**Semester:** 2024/25 Semester 2  
**Student:** Li Peisen (23126149r)

---

## Overview

The assignment focuses on processing real Intermediate Frequency (IF) datasets collected under two different environments:
- **OpenSky**: An environment with minimal obstructions and strong signal quality.
- **Urban**: A challenging environment with significant signal blockage, multipath interference, and urban noise.

---

## Task 1: Acquisition

### OpenSky Dataset
In the OpenSky dataset, acquisition results reveal:
- **Doppler Shift**: Varies between several hundred and a few thousand Hertz due to differences in relative satellite motion and receiver geometry. Minimal obstructions result in accurate Doppler estimates.
- **Code Phase**: Each satellite shows a distinct code phase value corresponding to its specific signal travel delay. Accurate code phase determination is crucial for reliable pseudorange measurements.
- **Fine Frequency**: Adjustments cluster around the intermediate frequency of 4.58 MHz, indicating a successful and precise acquisition process.
- **SNR**: High signal-to-noise ratios (e.g., SV16, SV31) confirm strong signal quality and minimal multipath effects.

![Task 1 OpenSky](images/Task1_OpenSky.png)

### Urban Dataset
The Urban dataset presents several challenges:
- **Doppler Shift**: Although the range remains similar, increased variability is observed due to complex signal paths and reflections.
- **Code Phase**: Greater deviations are noted, likely caused by signal blockage and multipath distortion, leading to less reliable pseudorange measurements.
- **Fine Frequency**: Slightly larger deviations indicate difficulty in achieving a stable lock in the presence of urban interference.
- **SNR**: Lower overall SNR values due to obstructions (e.g., buildings) and multipath effects, necessitating more robust acquisition and tracking strategies.

![Task 1 Urban](images/Task1_Urban.png)

---

## Task 2: Tracking

### OpenSky Dataset
Tracking performance in the OpenSky dataset is evidenced by:
- **Correlation Functions**: Well-defined early, prompt, and late peaks for both in-phase and quadrature-phase components. The prompt in-phase correlation peak is the highest, indicating precise code alignment and effective tracking.
- **Symmetry**: The symmetric early and late correlator values suggest that the tracking loop is successfully locked onto the true code phase.

![Task 2 OpenSky](images/Task2_OpenSky.png)

### Urban Dataset
In the Urban dataset, tracking is more challenging:
- **Correlation Functions**: The peaks are less pronounced, with the prompt in-phase peak appearing broader and less defined, indicating the impact of multipath and signal attenuation.
- **Increased Variability**: The quadrature-phase plots show greater fluctuations, reflecting additional noise and residual errors in carrier tracking. This underscores the need for robust tracking algorithms.

![Task 2 Urban](images/Task2_Urban.png)

---

## Task 3: Navigation Data Decoding

### OpenSky Dataset
The decoded ephemeris data for the OpenSky dataset are grouped into several categories:
- **Time-Related Parameters**: TOW, Week Number, toe, and toc provide essential timing references and confirm that the broadcast messages are consistent with the GPS epoch.
- **Satellite Clock Corrections**: Parameters such as af0, af1, af2, and IODC ensure accurate correction of satellite clock biases and drifts.
- **Orbital Parameters**: Elements like sqrtA, e, M0, Δn, and i0 (typically near 55°) conform to standard GPS orbits. Correction terms (Crs, Crc, Cus, Cuc, Cis, Cic) and TGD facilitate precise satellite position computations.
- **Update Flags**: Recent update flags confirm the reliability of the broadcast ephemeris.

![Task 3 OpenSky](images/Task3_OpenSky.png)

### Urban Dataset
In urban environments, severe signal blockage and multipath effects can lead to situations where only one satellite's navigation data is available. This is due to:
- **Severe Interference and Multipath**: Intense urban interference and pronounced multipath can degrade or completely block signals from most satellites.
- **Limited Usable Data**: Only the satellite with the most favorable geometry or the least obstruction may provide usable navigation data.

![Task 3 Urban](images/Task3_Urban.png)

---

## Task 4: Position and Velocity Estimation (WLS)

### OpenSky Dataset
Positioning via weighted least squares (WLS) in the OpenSky dataset shows small deviations from the ground truth due to:
- **Residual Errors**: Slight residual satellite clock and ephemeris errors remain even after applying standard corrections.
- **Atmospheric Delays**: Incomplete compensation for ionospheric and tropospheric delays introduces small offsets in pseudoranges.
- **Minor Multipath**: Minor reflections from nearby structures or the ground can slightly alter measured pseudoranges.
- **Satellite Geometry**: Suboptimal satellite geometry (GDOP effects) can amplify measurement noise.

![Task 4 OpenSky](images/Task4_OpenSky.png)

---

## Task 5: Kalman Filter-Based Positioning (EKF)

### OpenSky Dataset
An Extended Kalman Filter (EKF) is used for position and velocity estimation. Despite favorable conditions, the results differ from the ground truth due to:
- **Initial State Sensitivity**: Inaccuracies in the initial state can delay convergence or introduce bias.
- **Measurement Noise**: Residual errors in pseudorange and Doppler measurements (from minor clock/ephemeris errors and multipath) affect filter performance.
- **Noise Tuning**: Improper tuning of the EKF’s noise covariance parameters can lead to over- or under-correction.
- **Satellite Geometry**: Occasional suboptimal satellite geometry magnifies minor errors, impacting overall accuracy.

![Task 5 OpenSky](images/Task5_OpenSky.png)

---

## Summary

This report presents an analysis of GNSS signal processing across two environments:
- **OpenSky**: Exhibits strong signal quality with reliable acquisition, tracking, navigation data decoding, and positioning. Minor errors arise from residual satellite and atmospheric effects.
- **Urban**: Suffers from significant signal blockage, multipath interference, and urban noise, often resulting in reduced satellite visibility and degraded positioning performance.

The analysis emphasizes the need for robust algorithms and careful parameter tuning to achieve accurate GNSS navigation under varying environmental conditions.

---

## Repository Contents

- **Source Code**: Complete GNSS SDR signal processing implementation.
- **Datasets**: OpenSky and Urban IF datasets with detailed specifications.
- **Technical Report**: This README serves as an overview; refer to the full report for an in-depth analysis.

---

## Acknowledgments

- **Dr. Hoi-Fung Ng**
- **Teaching Assistants**
- **Course Lecturer**

---

Feel free to explore the repository for additional details and source code implementations.
