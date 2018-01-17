using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc.Rendering;
using Nop.Web.Framework.Mvc.ModelBinding;

namespace Nop.Plugin.DiscountRules.Affiliations.Models
{
    public class RequirementModel
    {
        public RequirementModel()
        {
            
        }

        [NopResourceDisplayName("Plugins.DiscountRules.Affiliations.Fields.Affiliation")]
        public string Affiliation { get; set; }

        public int DiscountId { get; set; }

        public int RequirementId { get; set; }
    }
}