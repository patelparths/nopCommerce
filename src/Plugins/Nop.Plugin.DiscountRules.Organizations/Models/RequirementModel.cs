using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc.Rendering;
using Nop.Web.Framework.Mvc.ModelBinding;

namespace Nop.Plugin.DiscountRules.Organizations.Models
{
    public class RequirementModel
    {
        public RequirementModel()
        {
            
        }

        [NopResourceDisplayName("Plugins.DiscountRules.Organizations.Fields.Organization")]
        public string Organization { get; set; }

        public int DiscountId { get; set; }

        public int RequirementId { get; set; }
    }
}