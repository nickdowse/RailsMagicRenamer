# RAILS REFACTOR Roadmap

Currently the gem is not a set and forget tool, you still need to do a lot of manual renaming afterward the gem has done its work. 

I would like this gem to rename much more comprehensively than it currently is, and as such will work towards completing these following steps, some of which have already been completed:

Could be issues with relations in non-model files.

Eg company.campaigns in the orders controller

Here --^ look for all associations and check the type of the caller. Not strictly a necessity as the type of the caller is what matters most not the name (eg company vs c)

* Check if there's already a model with the same name as what you're going to (file exists?)
* Check out new branch in git
* Change model file name (campaign.rb -> distribution.rb)
* Update class reference (class Campaign -> class Distribution)
* Update has_one/has_many/belongs_to relationships (eg has_many :campaigns -> has_many :distributions)
* Update :through relationships
* Update all classes that inherit from Campaign (class EmailCampign < Campaign -> class EmailCampaign < Distribution)
* Change all references to that file (Campaign.blah_blah_blah -> Distribution.blah_blah_blah)
* Change all references from model -> model (@pressdoc.campaigns -> @pressdoc.distributions)
* Update model folder (if necessary) (models/campaigns/.rb -> models/distributions/.rb)
* Update view folder (views/campaigns/* -> views/distributions/*)
* Update controller file names (campaigns_controller.rb -> distributions_controller.rb)
* Update controller class names incl w/ namespacing (class Manage::CampaignsController < Manage::ApplicationController -> class Manage::DistributionsController < Manage::ApplicationController)
* Update routes (namespace campaigns -> namespace distributions)
* Update paths (edit_manage_organisation_pressroom_pressdoc_campaign_path -> edit_manage_organisation_pressroom_pressdoc_distribution_path)
* Update URLs (edit_manage_organisation_pressroom_pressdoc_campaign_url -> edit_manage_organisation_pressroom_pressdoc_distribution_url)
* Update instance variables (@campaign -> @distribution)
* Create rename_table migration for main model table
* Create rename_table migration for all relevant pivot/join tables
* Create migration to rename foreign keys (eg email.campaign_id -> email.distribution_id)
* Run migrations
* Update specs (campaign_spec.rb -> distribution_spec.rb)
* Update factories (campaign_factory -> distribution_factory)
* Run specs
