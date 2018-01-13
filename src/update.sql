
-- Add discount is appproved or not column
ALTER TABLE Discount ADD IsApproved int not null default(0);

-- Insert discount approver role in table.
Insert into CustomerRole(Name,FreeShipping,TaxExempt,Active,IsSystemRole,SystemName,
					     EnablePasswordLifetime,OverrideTaxDisplayType,DefaultTaxDisplayTypeId,
						 PurchasedWithProductId)
	values ('Discount Approver',0,0,1,1,'DiscountApprover',	0,	0,	0,	0)

-- Insert localisation in table
Insert into LocaleStringResource(LanguageId, ResourceName, ResourceValue)
	values(1,'admin.promotions.discounts.fields.isapproved','Is Approved')

Insert into LocaleStringResource(LanguageId, ResourceName, ResourceValue)
	values(1,'admin.common.approve','Approve Discount')

Insert into LocaleStringResource(LanguageId, ResourceName, ResourceValue)
	values(1,'admin.common.unapprove','Reject Discount')

Insert into LocaleStringResource(LanguageId, ResourceName, ResourceValue)
	values(1,'discount.approved.success','Discount approved successfully')

Insert into LocaleStringResource(LanguageId, ResourceName, ResourceValue)
	values(1,'discount.unapproved.success','Discount rejected successfully')
