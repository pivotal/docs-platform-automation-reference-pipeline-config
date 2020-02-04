## Platform Automation Reference Pipeline PKS Configs

These configs are used
in the [Platform Automation reference pipeline.](http://docs.pivotal.io/platform-automation/v3.0/pipeline/multiple-products.html)
You may clone this repository
and use it as a reference for your own configurations.

### Design Considerations

* The example pipelines that have configuration/vars (`CONFIG_PATHS`/`VARS_PATHS`)
that come from multiple locations
are intentionally written from *least* specific to *most* specific
in order to give priority to foundation specific properties over the common properties.
* Config file location considerations:
  * We considered using a `foundations/common` folder
    in order to hold common configuration.
    We decided to pull the `config` and `vars`
    folders up a level (to live in `foundations`)
    so as to not give the impression that `common`
    is a foundation name.
  * When it comes to `config` files,
    due to the fact that most Platform Automation tasks do not allow for multiple config files,
    we decided that having tile configuration in *either* the `foundations/config` folder *or* the `foundations/((foundation))/config` folder
    reduces the chance of getting the wrong configuration by mistake.
  * Additionally, this helps to enable config promotion by allowing for the differences in config files between product versions.
  * Common vars between tile configurations can exist at the top level `foundations/vars` folder
    where they can be used in *addition* to the foundation-specific variables for that tile.
    Multiple files can be specified in all relevant Platform Automation tasks by using space separated paths in the `VARS_FILES` param.
