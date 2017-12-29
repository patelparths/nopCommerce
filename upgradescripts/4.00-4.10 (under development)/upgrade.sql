--upgrade scripts from nopCommerce 4.00 to 4.10

--new locale resources
declare @resources xml
--a resource will be deleted if its value is empty
set @resources='
<Language>
  <LocaleResource Name="Admin.Configuration.Currencies.Fields.CurrencyCode.Hint">
    <Value>The currency code. For a list of currency codes, go to: https://en.wikipedia.org/wiki/ISO_4217</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Customers.Customers.Fields.Avatar">
    <Value>Avatar</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Configuration.Settings.Catalog.ExportImportAllowDownloadImages">
    <Value>Export/Import products. Allow download images</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Configuration.Settings.Catalog.ExportImportAllowDownloadImages.Hint">
    <Value>Check if images can be downloaded from remote server when exporting products</Value>
  </LocaleResource> 
  <LocaleResource Name="Admin.ContentManagement.Topics.List.SearchKeywords">
    <Value>Search keywords</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.ContentManagement.Topics.List.SearchKeywords.Hint">
    <Value>Search topic(s) by specific keywords.</Value>
  </LocaleResource>  
  <LocaleResource Name="Admin.Configuration.Settings.Catalog.ShowProductReviewsPerStore.Hint">
    <Value>Check to display reviews written in the current store only (on a product details page and on the account product reviews page).</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Catalog.ViewMode.Grid">
    <Value>Grid</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Catalog.ViewMode.List">
    <Value>List</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Configuration.Settings.Catalog.DefaultViewMode">
    <Value>Default view mode</Value>
  </LocaleResource>    
  <LocaleResource Name="Admin.Configuration.Settings.Catalog.DefaultViewMode.Hint">
    <Value>Choose the default view mode for catalog pages.</Value>
  </LocaleResource>     
  <LocaleResource Name="Admin.Promotions.Discounts.List.SearchEndDate">
    <Value>End date</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Promotions.Discounts.List.SearchEndDate.Hint">
    <Value>The end date for the search.</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Promotions.Discounts.List.SearchStartDate">
    <Value>Start date</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Promotions.Discounts.List.SearchStartDate.Hint">
    <Value>The start date for the search.</Value>
  </LocaleResource>
  <LocaleResource Name="Enums.Nop.Core.Domain.Security.UserRegistrationType.AdminApproval">
    <Value></Value>
  </LocaleResource>
  <LocaleResource Name="Enums.Nop.Core.Domain.Security.UserRegistrationType.Disabled">
    <Value></Value>
  </LocaleResource>
  <LocaleResource Name="Enums.Nop.Core.Domain.Security.UserRegistrationType.EmailValidation">
    <Value></Value>
  </LocaleResource>
  <LocaleResource Name="Enums.Nop.Core.Domain.Security.UserRegistrationType.Standard">
    <Value></Value>
  </LocaleResource>
  <LocaleResource Name="Enums.Nop.Core.Domain.Customers.UserRegistrationType.AdminApproval">
    <Value>A customer should be approved by administrator</Value>
  </LocaleResource>
  <LocaleResource Name="Enums.Nop.Core.Domain.Customers.UserRegistrationType.Disabled">
    <Value>Registration is disabled</Value>
  </LocaleResource>
  <LocaleResource Name="Enums.Nop.Core.Domain.Customers.UserRegistrationType.EmailValidation">
    <Value>Email validation is required after registration</Value>
  </LocaleResource>
  <LocaleResource Name="Enums.Nop.Core.Domain.Customers.UserRegistrationType.Standard">
    <Value>Standard account creation</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Catalog.Products.Fields.EmailAdminWhenMinStockQuantity">
    <Value>Email admin when minimum stock quantity</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Catalog.Products.Fields.EmailAdminWhenMinStockQuantity.Hint">
    <Value>When the current stock quantity falls below minimum stock quantity, a store owner will receive a notification.</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Catalog.Products.Fields.NotifyAdminForQuantityBelow">
    <Value></Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Catalog.Products.Fields.NotifyAdminForQuantityBelow.Hint">
    <Value></Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Catalog.Products.ProductAttributes.AttributeCombinations.Fields.EmailAdminWhenMinStockQuantity">
    <Value>Email admin when minimum stock quantity</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Catalog.Products.ProductAttributes.AttributeCombinations.Fields.EmailAdminWhenMinStockQuantity.Hint">
    <Value>When the current stock quantity falls below minimum stock quantity, a store owner will receive a notification.</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Catalog.Products.ProductAttributes.AttributeCombinations.Fields.MinStockQuantity">
    <Value>Minimum stock qty</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Catalog.Products.ProductAttributes.AttributeCombinations.Fields.MinStockQuantity.Hint">
    <Value>If you have enabled ''Manage stock by product attributes'' you can receive an email notification when the current stock quantity falls below (reaches) your minimum stock quantity.</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Catalog.Products.ProductAttributes.AttributeCombinations.Fields.NotifyAdminForQuantityBelow">
    <Value></Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Catalog.Products.ProductAttributes.AttributeCombinations.Fields.NotifyAdminForQuantityBelow.Hint">
    <Value></Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Configuration.Settings.ProductEditor.EmailAdminWhenMinStockQuantity">
    <Value>Email admin when minimum stock quantity</Value>
  </LocaleResource>
  <LocaleResource Name="Admin.Configuration.Settings.ProductEditor.NotifyAdminForQuantityBelow">
    <Value></Value>
  </LocaleResource>
</Language>
'

CREATE TABLE #LocaleStringResourceTmp
	(
		[ResourceName] [nvarchar](200) NOT NULL,
		[ResourceValue] [nvarchar](max) NOT NULL
	)

INSERT INTO #LocaleStringResourceTmp (ResourceName, ResourceValue)
SELECT	nref.value('@Name', 'nvarchar(200)'), nref.value('Value[1]', 'nvarchar(MAX)')
FROM	@resources.nodes('//Language/LocaleResource') AS R(nref)

--do it for each existing language
DECLARE @ExistingLanguageID int
DECLARE cur_existinglanguage CURSOR FOR
SELECT [ID]
FROM [Language]
OPEN cur_existinglanguage
FETCH NEXT FROM cur_existinglanguage INTO @ExistingLanguageID
WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @ResourceName nvarchar(200)
	DECLARE @ResourceValue nvarchar(MAX)
	DECLARE cur_localeresource CURSOR FOR
	SELECT ResourceName, ResourceValue
	FROM #LocaleStringResourceTmp
	OPEN cur_localeresource
	FETCH NEXT FROM cur_localeresource INTO @ResourceName, @ResourceValue
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (EXISTS (SELECT 1 FROM [LocaleStringResource] WHERE LanguageID=@ExistingLanguageID AND ResourceName=@ResourceName))
		BEGIN
			UPDATE [LocaleStringResource]
			SET [ResourceValue]=@ResourceValue
			WHERE LanguageID=@ExistingLanguageID AND ResourceName=@ResourceName
		END
		ELSE 
		BEGIN
			INSERT INTO [LocaleStringResource]
			(
				[LanguageId],
				[ResourceName],
				[ResourceValue]
			)
			VALUES
			(
				@ExistingLanguageID,
				@ResourceName,
				@ResourceValue
			)
		END
		
		IF (@ResourceValue is null or @ResourceValue = '')
		BEGIN
			DELETE [LocaleStringResource]
			WHERE LanguageID=@ExistingLanguageID AND ResourceName=@ResourceName
		END
		
		FETCH NEXT FROM cur_localeresource INTO @ResourceName, @ResourceValue
	END
	CLOSE cur_localeresource
	DEALLOCATE cur_localeresource


	--fetch next language identifier
	FETCH NEXT FROM cur_existinglanguage INTO @ExistingLanguageID
END
CLOSE cur_existinglanguage
DEALLOCATE cur_existinglanguage

DROP TABLE #LocaleStringResourceTmp
GO

--new index
IF NOT EXISTS (SELECT 1 from sys.indexes WHERE [NAME]=N'IX_GetLowStockProducts' and object_id=object_id(N'[dbo].[Product]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_GetLowStockProducts] ON [Product] (Deleted ASC, VendorId ASC, ProductTypeId ASC, ManageInventoryMethodId ASC, MinStockQuantity ASC, UseMultipleWarehouses ASC)
END
GO

--new setting
IF NOT EXISTS (SELECT 1 FROM [Setting] WHERE [name] = N'catalogsettings.exportimportallowdownloadimages')
BEGIN
	INSERT [Setting] ([Name], [Value], [StoreId])
	VALUES (N'catalogsettings.exportimportallowdownloadimages', N'false', 0)
END
GO

--new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('[ActivityLog]') AND NAME = 'EntityId')
BEGIN
	ALTER TABLE [ActivityLog]
	ADD [EntityId] INT NULL
END
GO

--new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('[ActivityLog]') AND NAME = 'EntityName')
BEGIN
	ALTER TABLE [ActivityLog]
	ADD [EntityName] NVARCHAR(400) NULL
END
GO

--new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('[ProductAttributeCombination]') AND NAME = 'MinStockQuantity')
BEGIN
	ALTER TABLE [ProductAttributeCombination]
	ADD [MinStockQuantity] INT NULL
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('[ProductAttributeCombination]') and NAME = 'NotifyAdminForQuantityBelow')
BEGIN
    EXEC('
        UPDATE [ProductAttributeCombination]
        SET [MinStockQuantity] = [NotifyAdminForQuantityBelow]
        WHERE [MinStockQuantity] IS NULL')
END
ELSE
BEGIN
	UPDATE [ProductAttributeCombination]
	SET [MinStockQuantity] = 0
	WHERE [MinStockQuantity] IS NULL
END
GO

ALTER TABLE [ProductAttributeCombination] ALTER COLUMN [MinStockQuantity] INT NOT NULL
GO

--new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('[ProductAttributeCombination]') AND NAME = 'EmailAdminWhenMinStockQuantity')
BEGIN
	ALTER TABLE [ProductAttributeCombination]
	ADD [EmailAdminWhenMinStockQuantity] BIT NULL
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('[ProductAttributeCombination]') and NAME = 'NotifyAdminForQuantityBelow')
BEGIN
    EXEC('
        UPDATE [ProductAttributeCombination]
        SET [EmailAdminWhenMinStockQuantity] = 
			CASE
				WHEN [NotifyAdminForQuantityBelow] > 0 THEN 1 
				ELSE 0 
			END
        WHERE [EmailAdminWhenMinStockQuantity] IS NULL')
END
ELSE
BEGIN
	UPDATE [ProductAttributeCombination]
	SET [EmailAdminWhenMinStockQuantity] = 0
	WHERE [EmailAdminWhenMinStockQuantity] IS NULL
END
GO

ALTER TABLE [ProductAttributeCombination] ALTER COLUMN [EmailAdminWhenMinStockQuantity] BIT NOT NULL
GO

--drop column
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('[ProductAttributeCombination]') AND NAME = 'NotifyAdminForQuantityBelow')
BEGIN
	ALTER TABLE [ProductAttributeCombination] DROP COLUMN [NotifyAdminForQuantityBelow]
END
GO

--new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('[Product]') AND NAME = 'EmailAdminWhenMinStockQuantity')
BEGIN
	ALTER TABLE [Product]
	ADD [EmailAdminWhenMinStockQuantity] BIT NULL
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('[Product]') and NAME = 'NotifyAdminForQuantityBelow')
BEGIN
    EXEC('
        UPDATE [Product]
        SET [EmailAdminWhenMinStockQuantity] = 
			CASE
				WHEN [NotifyAdminForQuantityBelow] > 0 THEN 1 
				ELSE 0 
			END
        WHERE [EmailAdminWhenMinStockQuantity] IS NULL')
END
ELSE
BEGIN
	UPDATE [Product]
	SET [EmailAdminWhenMinStockQuantity] = 0
	WHERE [EmailAdminWhenMinStockQuantity] IS NULL
END
GO

ALTER TABLE [Product] ALTER COLUMN [EmailAdminWhenMinStockQuantity] BIT NOT NULL
GO

--drop column
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('[Product]') AND NAME = 'NotifyAdminForQuantityBelow')
BEGIN
	ALTER TABLE [Product] DROP COLUMN [NotifyAdminForQuantityBelow]
END
GO

--new setting
IF NOT EXISTS (SELECT 1 FROM [Setting] WHERE [name] = N'producteditorsettings.emailadminwhenminstockquantity')
BEGIN
	INSERT [Setting] ([Name], [Value], [StoreId])
	VALUES (N'producteditorsettings.emailadminwhenminstockquantity', N'false', 0)
END
GO

--delete setting
DELETE FROM [Setting]
WHERE [Name] = N'producteditorsettings.notifyadminforquantitybelow'
GO