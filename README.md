## Platform Automation Reference Pipeline Configs

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
* Tile versioning
  * Versions for downloading from pivnet are defined as regular expressions within the appropriate download product configuration files.
  * Versions for each environment's tiles are defined explicitly in the `foundations/((foundation))/vars/versions.yml` file.
    This enables the use case of updating a tile on one foundation before promoting that configuration to the other foundations.

### Config Promotion Example

In this example, we will be updating PKS from 1.3.8 to 1.4.3.
We will start with updating this tile in our Sandbox foundation
and then promote the configuration to the development foundation.

1. Update `download-product-pivnet/download-pks.yml`:

    ```diff
    - product-version-regex: ^1\.3\..*$
    + product-version-regex: ^1\.4\..*$
    ```

1. Commit this change and run the pipeline
which will download the 1.4.3 PKS tile
and make it available on S3.

1. Update the versions file for sandbox:

    ```diff
    - pks-version: 1.3.8
    + pks-version: 1.4.3
    ```

1. Run the `upload-and-stage-pks` job, but do not run the `configure-pks` or `apply-product-changes` jobs.

    This makes it so that the `apply-changes` step won't automatically fail
    if there are configuration changes
    between what we currently have deployed
    and the new tile.

1. Optional if the tile has unconfigured properties:

    a. Manually configure the tile, deploy, and re-export the staged-config:

        ```
        om -e env.yml staged-config --include-credentials -p pivotal-container-service
        ```

1. Update `foundations/sandbox`

    a. Merge the resulting config with the existing `foundations/sandbox/config/pks.yml`.

        Diffing the previous `pks.yml`
        and the new one makes this process much easier.

    b. Pull out any configuration
    that is expected to be different or the same
    between sandbox and development.

        This can be done by putting property references in the `foundations/sandbox/config/pks.yml` file.
        The values for those property references can then be put in vars files
        at the foundations or foundations/<foundation> levels,
        or can be stored directly in credhub.

1. Commit any changes and run the `configure-pks` and `apply-product-changes` jobs.

1. Assuming the sandbox pipeline is all green,
copy the `foundations/sandbox/config` folder into `foundations/development`.

1. Modify the `foundations/development/vars/versions.yml` and `foundations/development/vars/pks.yml` files
to have all of the property references that exist in their sandbox counterparts
as well as the foundation-specific values.

1. Commit these changes and run the development pipeline all the way through.
