# Glass and graphics settings

## Adaptive Glass

The **Benchmark glass rendering** action runs a bounded 1.8-second preview with two translucent blur surfaces. Nova records Flutter raster frame timings and uses the 95th percentile together with logical processor count and physical display pixel count to recommend Low, Balanced, or High glass quality. The recommendation is saved with the app settings. The quality selector remains available for manual control; choosing a quality turns off Adaptive Glass.

This is a sample of Nova's raster workload under the current window conditions. Flutter does not expose the GPU model, GPU utilization, or dedicated graphics memory to this app, so the result is not a hardware inventory or a GPU-only benchmark.

## Windows GPU preference

The Windows **Hardware Acceleration** setting stores the user's choice in the Nova registry key and app settings. At next launch, Nova requests Windows' high-performance GPU preference when enabled and leaves adapter selection at the Windows default when disabled. Flutter's GPU renderer remains enabled in both modes; this option does not switch rendering to software mode. Restart Nova Music after changing the preference.
