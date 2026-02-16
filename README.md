Computational-Oceanography-Commentary
==============================
[![License:MIT](https://img.shields.io/badge/License-MIT-lightgray.svg?style=flt-square)](https://opensource.org/licenses/MIT)

MATLAB code to make figures for computational oceanography commentary.

Build three figures from the MATLAB subdirectories

* `Turing_test.pdf` from running `plot_DSO_overflow.m`, `plot_hydrography.m`, `plot_float_trajectories.m` then annotating in keynote. Data for this figure comes from [Haine (2010)](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2010GL043272) and [Saberi et al. (2020)](https://doi.org/10.1175/JPO-D-19-0210.1).
* `data_plot.pdf` from running `make_data_plot.m` then annotating in keynote. This code uses [World Ocean Atlas](https://www.ncei.noaa.gov/products/world-ocean-database) data.
* `scales_plot.pdf` from running `scales_diagram.m` then annotating in keynote. This code is adapted from [Klinger & Haine (2019) Fig. 1.10.](https://www.cambridge.org/core/books/ocean-circulation-in-three-dimensions/BA67744EF2B76C3FCB239BCBF9D18271).

This commentary, entitled *Is Computational Oceanography Coming of Age?* is published by the Bulletin of the American Meteorological Society. See the paper here: [Haine et al. (2021)](https://journals.ametsoc.org/view/journals/bams/102/8/BAMS-D-20-0258.1.xml).

--------

<p><small>Project based on the <a target="_blank" href="https://github.com/jbusecke/cookiecutter-science-project">cookiecutter science project template</a>.</small></p>
