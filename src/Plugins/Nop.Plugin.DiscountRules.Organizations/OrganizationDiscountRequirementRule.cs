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

namespace Nop.Plugin.DiscountRules.Organizations
{
    public partial class OrganizationDiscountRequirementRule : BasePlugin, IDiscountRequirementRule
    {
        #region Fields

        private readonly IActionContextAccessor _actionContextAccessor;
        private readonly IDiscountService _discountService;
        private readonly ISettingService _settingService;
        private readonly IUrlHelperFactory _urlHelperFactory;

        #endregion

        #region Ctor

        public OrganizationDiscountRequirementRule(IActionContextAccessor actionContextAccessor,
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
            var restrictedOrganization = _settingService.GetSettingByKey<string>(string.Format(DiscountRequirementDefaults.SettingsKey, request.DiscountRequirementId));
            if (string.IsNullOrEmpty(restrictedOrganization))
                return result;

            //result is valid if the customer belongs to the restricted organization
            var customerOrganization = request.Customer.GetAttribute<string>(SystemCustomerAttributeNames.Organizations);
            if (string.IsNullOrEmpty(customerOrganization))
                return result;

            result.IsValid =  Glob.Glob.IsMatch(customerOrganization, restrictedOrganization);

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
            return urlHelper.Action("Configure", "DiscountRulesOrganizations",
                new { discountId = discountId, discountRequirementId = discountRequirementId }).TrimStart('/');
        }

        /// <summary>
        /// Install the plugin
        /// </summary>
        public override void Install()
        {
            //locales
            this.AddOrUpdatePluginLocaleResource("Plugins.DiscountRules.Organizations.Fields.Organization", "Required organization");
            this.AddOrUpdatePluginLocaleResource("Plugins.DiscountRules.Organizations.Fields.Organization.Hint", "Discount will be applied if customer is in the selected organization.");
            this.AddOrUpdatePluginLocaleResource("Plugins.DiscountRules.Organizations.Fields.Organizations.Select", "Enter Organization");

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
            this.DeletePluginLocaleResource("Plugins.DiscountRules.Organizations.Fields.Organizations");
            this.DeletePluginLocaleResource("Plugins.DiscountRules.Organizations.Fields.Organizations.Hint");
            this.DeletePluginLocaleResource("Plugins.DiscountRules.Organizations.Fields.Organizations.Select");

            base.Uninstall();
        }

        #endregion
    }
}