using System;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.Routing;
using Nop.Core.Plugins;
using Nop.Services.Configuration;
using Nop.Services.Discounts;
using Nop.Services.Localization;
using Nop.Services.Common;
using Nop.Core.Domain.Customers;

namespace Nop.Plugin.DiscountRules.Affiliations
{
    public partial class AffiliationDiscountRequirementRule : BasePlugin, IDiscountRequirementRule
    {
        #region Fields

        private readonly IActionContextAccessor _actionContextAccessor;
        private readonly IDiscountService _discountService;
        private readonly ISettingService _settingService;
        private readonly IUrlHelperFactory _urlHelperFactory;

        #endregion

        #region Ctor

        public AffiliationDiscountRequirementRule(IActionContextAccessor actionContextAccessor,
            IDiscountService discountService,
            ISettingService settingService,
            IUrlHelperFactory urlHelperFactory)
        {
            this._actionContextAccessor = actionContextAccessor;
            this._discountService = discountService;
            this._settingService = settingService;
            this._urlHelperFactory = urlHelperFactory;
        }

        #endregion

        #region Methods

        /// <summary>
        /// Check discount requirement
        /// </summary>
        /// <param name="request">Object that contains all information required to check the requirement (Current customer, discount, etc)</param>
        /// <returns>Result</returns>
        public DiscountRequirementValidationResult CheckRequirement(DiscountRequirementValidationRequest request)
        {
            if (request == null)
                throw new ArgumentNullException(nameof(request));

            //invalid by default
            var result = new DiscountRequirementValidationResult();

            if (request.Customer == null)
                return result;

            //try to get saved restricted customer organization
            var restrictedAffiliation = _settingService.GetSettingByKey<string>(string.Format(DiscountRequirementDefaults.SettingsKey, request.DiscountRequirementId));
            if (string.IsNullOrEmpty(restrictedAffiliation))
                return result;

            //result is valid if the customer belongs to the restricted organization
            result.IsValid = request.Customer.GetAttribute<string>(SystemCustomerAttributeNames.Affiliations).Contains(restrictedAffiliation);

            return result;
        }

        /// <summary>
        /// Get URL for rule configuration
        /// </summary>
        /// <param name="discountId">Discount identifier</param>
        /// <param name="discountRequirementId">Discount requirement identifier (if editing)</param>
        /// <returns>URL</returns>
        public string GetConfigurationUrl(int discountId, int? discountRequirementId)
        {
            var urlHelper = _urlHelperFactory.GetUrlHelper(_actionContextAccessor.ActionContext);
            return urlHelper.Action("Configure", "DiscountRulesAffiliations",
                new { discountId = discountId, discountRequirementId = discountRequirementId }).TrimStart('/');
        }

        /// <summary>
        /// Install the plugin
        /// </summary>
        public override void Install()
        {
            //locales
            this.AddOrUpdatePluginLocaleResource("Plugins.DiscountRules.Affiliations.Fields.Affiliation", "Required affiliation");
            this.AddOrUpdatePluginLocaleResource("Plugins.DiscountRules.Affiliations.Fields.Affiliation.Hint", "Discount will be applied if customer is in the selected affiliation.");
            this.AddOrUpdatePluginLocaleResource("Plugins.DiscountRules.Affiliations.Fields.Affiliations.Select", "Enter Affiliation");

            base.Install();
        }

        /// <summary>
        /// Uninstall the plugin
        /// </summary>
        public override void Uninstall()
        {
            //discount requirements
            var discountRequirements = _discountService.GetAllDiscountRequirements()
                .Where(discountRequirement => discountRequirement.DiscountRequirementRuleSystemName == DiscountRequirementDefaults.SystemName);
            foreach (var discountRequirement in discountRequirements)
            {
                _discountService.DeleteDiscountRequirement(discountRequirement);
            }

            //locales
            this.DeletePluginLocaleResource("Plugins.DiscountRules.Affiliations.Fields.Affiliation");
            this.DeletePluginLocaleResource("Plugins.DiscountRules.Affiliations.Fields.Affiliation.Hint");
            this.DeletePluginLocaleResource("Plugins.DiscountRules.Affiliations.Fields.Affiliations.Select");

            base.Uninstall();
        }

        #endregion
    }
}