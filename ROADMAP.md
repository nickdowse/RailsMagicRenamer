# RAILS MAGIC RENAMER Roadmap

Currently the gem is not a set and forget tool, you still need to do a lot of manual renaming afterward the gem has done its work. 

I would like this gem to rename much more comprehensively than it currently is, and as such will work towards completing these following steps, some of which have already been completed:

Could be issues with relations in non-model files.

Eg company.campaigns in the orders controller

Here --^ look for all associations and check the type of the caller. Not strictly a necessity as the type of the caller is what matters most not the name (eg company vs c)

* Create a comprehensive fake rails app. - Yes

### Model Checks
* Check if there's already a model with the same name as what you're going to (file exists?) -> Yes
* Commit what we have in git - Yes
* Change model file name (campaign.rb -> distribution.rb) - Yes
* Update model folder (if necessary) (models/campaigns/.rb -> models/distributions/.rb) - Yes
* Update class reference (class Campaign -> class Distribution) - Yes
* Update has_one/has_many/belongs_to relationships (eg has_many :campaigns -> has_many :distributions) - Scaffolded
* Update :through relationships - Scaffolded
* Update relationships in classes that have a relationship with from - Scaffolded
* Update all classes that inherit from Campaign (class EmailCampign < Campaign -> class EmailCampaign < Distribution) - Scaffolded

### Global checks
* Change all references to that file (Campaign.blah_blah_blah -> Distribution.blah_blah_blah) (Global find and replace of `Campaign` to `Distribution`)
* Global find and replace of lower_case `campaign` to `distribution`
- Here make certain to skip database folder
- This will Change all references from model -> model (@pressdoc.campaigns -> @pressdoc.distributions) -> Similar to above where it takes the file and replaces all instances of 'campaigns' with 'campaign'. It will also update instance variables (@campaign -> @distribution)


### View checks
* Update view folder (views/campaigns/* -> views/distributions/*)

### Controller checks
* Update controller file names (campaigns_controller.rb -> distributions_controller.rb)
* Update controller class names incl w/ namespacing (class Manage::CampaignsController < Manage::ApplicationController -> class Manage::DistributionsController < Manage::ApplicationController)

### Routing/Path checks
* Update routes (namespace campaigns -> namespace distributions)
* Update paths (edit_manage_organisation_pressroom_pressdoc_campaign_path -> edit_manage_organisation_pressroom_pressdoc_distribution_path)
* Update URLs (edit_manage_organisation_pressroom_pressdoc_campaign_url -> edit_manage_organisation_pressroom_pressdoc_distribution_url)

### Database checks
* Create rename_table migration for main model table
* Create rename_table migration for all relevant pivot/join tables
* Create migration to rename foreign keys (eg email.campaign_id -> email.distribution_id)
* Run migrations

# Spec checks
* Update specs (campaign_spec.rb -> distribution_spec.rb)
* Update factories (campaign_factory -> distribution_factory)
* Run specs

### Other
* Update README to new name