
namespace Nop.Plugin.DiscountRules.Affiliations
{
    /// <summary>
    /// Represents constants for the discount requirement rule
    /// </summary>
    public static class DiscountRequirementDefaults
    {
        /// <summary>
        /// The system name of the discount requirement rule
        /// </summary>
        public const string SystemName = "DiscountRequirement.MustBeAssignedToAffiliation";

        /// <summary>
        /// The key of the settings to save restricted customer roles
        /// </summary>
        public const string SettingsKey = "DiscountRequirement.MustBeAssignedToAffiliation-{0}";

        /// <summary>
        /// The HTML field prefix for discount requirements
        /// </summary>
        public const string HtmlFieldPrefix = "DiscountRulesAffiliations{0}";
    }
}
