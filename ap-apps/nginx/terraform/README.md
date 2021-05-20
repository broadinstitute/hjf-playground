In order to successfully run terraform using these files you musts create the following additional files:
 * providers.tf : This file should define both the google and google-beta provider with an alias of "ap-env"
 * terraform.tfvars : This file should initialize the two required variables:
   * ap-app-zone
   * ap-app-name

