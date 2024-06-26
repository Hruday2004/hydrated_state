Filters
=========

Applied filters for the fiducial point detection and benchmarking:
------------------------------------------------------------------

During the benchmarking, for all toolboxes, the PPG signals were filtered between *0.5–12 Hz*. In the case of *pyPPG* and *PPGFeat*, this was performed using the built-in filtering capabilities of these toolboxes. However, for *PulseAnalyse*, we provided pre-filtered data as input to the toolbox as the toolbox's high-pass filtering functionality requires a longer signal duration than that used in this study.

The following zero-phase filters were implemented in the *pyPPG*:

    - **Bandpass filtering between 0.5-12 Hz**: A fourth-order Chebyshev Type II filter was used for the original signal. The 12 Hz low-pass cut-off was used to avoid time-shifting of fiducial points (particularly pulse onset, and dicrotic notch) and to eliminate unwanted high-frequency content from the PPG derivatives. The 0.5 Hz high-pass cut-off was used to minimize baseline wandering whilst retaining content at low heart rates.
    - **50 ms moving average filtering (MAF)**: In the case of very noisy signals, some high-frequency content can remain in the band-pass filter signal. For this purpose, a 50 ms standard flat (boxcar or top-hat) MAF with a 9 Hz cut-off frequency was applied after the band-pass filtering.
    - **10 ms MAF for the PPG derivatives**: To eliminate the high-frequency content in the PPG derivatives, a 10 ms standard flat (boxcar or top-hat) MAF with 45 Hz cut-off frequency was applied.