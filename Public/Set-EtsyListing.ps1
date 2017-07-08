<#
.SYNOPSIS
Updates a single Etsy listing's information.

.DESCRIPTION
WARNING: Updating a listing causes Etsy to attempt to activate that listing. This may result in charges to the shop.

.PARAMETER ConsumerKey
A PSCredential object containing the consumer key as the password. The username can be anything. If tokens were stored using Request-EtsyOauthToken, then this field is not required.

.PARAMETER ConsumerSecret
A PSCredential object containing the consumer secret as the password. The username can be anything. If tokens were stored using Request-EtsyOauthToken, then this field is not required.

.PARAMETER Token
A PSCredential object containing the OAuth token as the password. This is received through the OAuth token request process. The username can be anything.
If tokens were stored using Request-EtsyOauthToken, then this field is not required.

.PARAMETER TokenSecret
A PSCredential object containing the OAuth token secret as the password. This is received through the OAuth token request process. The username can be anything. If tokens were stored using Request-EtsyOauthToken, then this field is not required.

.PARAMETER ListingID
The listing's numeric ID.

.PARAMETER Title
The listing's title. This string is valid if it does not match the following pattern: /[^\p{L}\p{Nd}\p{P}\p{Sm}\p{Zs}™©®]/u. The characters %, :, & and + can only be used once each.

.PARAMETER Description
A description of the item(s).

.PARAMETER Materials
List/array of materials used to create listed item(s).

.PARAMETER Renew
Set to $true if you wish to renew the listing. NOTE: This will cause the shop to be charged!

.PARAMETER ShippingTemplateID
The numeric ID of the shipping template to be associated with the listing.

.PARAMETER ShopSectionID
The numeric ID of the shop section for this listing.

.PARAMETER State
One of active, inactive, or draft.

.PARAMETER IsCustomizable
If set to $true, a buyer may contact the seller for a customized order. Can only be set when the shop accepts custom orders and defaults to true in that case.

.PARAMETER ItemWeight
How much the item weighs.

.PARAMETER ItemLength
How long the item is.

.PARAMETER ItemWidth
How wide the item is.

.PARAMETER ItemHeight
How tall the item is.

.PARAMETER ItemWeightUnit
The units used to represent the weight of this item. Can be one of the following: oz, lb, g, kg.
NOTE: Must be all lowercase!

.PARAMETER ItemDimensionsUnit
The units used to represent the dimensions of this item. Can be one of the following: in, ft, mm, cm, m.
NOTE: Must be all lowercase!

.PARAMETER NonTaxable
If set to $true, any applicable shop tax rates will not be applied to this listing on checkout.

.PARAMETER CategoryID
The numeric ID of the listing's category.

.PARAMETER TaxonomyID
The seller taxonomy id of the listing.

.PARAMETER Tags
A list/array of tags for the item. A tag is valid if it does not match the pattern: /[^\p{L}\p{Nd}\p{Zs}\-'™©®]/u.

.PARAMETER WhoMade
Who made the item being listed. Can be one of the following: i_did, collective, someone_else.
NOTE: Must be all lowercase!

.PARAMETER IsSupply
Set to $true if the listing is a supply.

.PARAMETER WhenMade
When was the item made. Can be one of the following: made_to_order, 2010_2017, 2000_2009, 1998_1999, before_1998, 1990_1997, 1980s, 1970s, 1960s, 1950s, 1940s, 1930s, 1920s, 1910s, 1900s, 1800s, 1700s, before_1700
NOTE: Must be all lowercase!

.PARAMETER Recipient
Who is this listing for. Can be one of the following: men, women, unisex_adults, teen_boys, teen_girls, teens, boys, girls, children, baby_boys, baby_girls, babies, birds, cats, dogs, pets, not_specified.
NOTE: Must be all lowercase!

.PARAMETER Occasion
The occasion for this listing. Can be one of the following: anniversary, baptism, bar_or_bat_mitzvah, birthday, canada_day, chinese_new_year, cinco_de_mayo, confirmation, christmas, day_of_the_dead, easter, eid, engagement, fathers_day, get_well, graduation, halloween, hanukkah, housewarming, kwanzaa, prom, july_4th, mothers_day, new_baby, new_years, quinceanera, retirement, st_patricks_day, sweet_16, sympathy, thanksgiving, valentines, wedding.
NOTE: Must be all lowercase!

.PARAMETER Style
Style of this listing. Each style is a free-form text string such as "Formal", or "Steampunk". A Listing may have up to two styles. A style is valid if it does not match the pattern: /[^\p{L}\p{Nd}\p{Zs}]/u.

.PARAMETER ProcessingMin
The minimum number of days for processing for this listing.

.PARAMETER ProcessingMax
The maximum number of days for processing for this listing.

.PARAMETER FeaturedRank
Position in the Featured Listings portion of the shop.

.EXAMPLE
$splat =
@{
    ListingID = 0123456789
    Title = 'Test Listing'
    Description = 'Test description'
    Style = 'Vintage','Retro'
    WhoMade = 'i_did'
}
Set-EtsyListing @splat
This example assumes that the tokens have been stored using Request-EtsyOauthToken. Listing 0123456789's title, description, style, and who_made will all be modified. All other fields will be unchanged.

#>
function Set-EtsyListing {
    param (
        [int]$ListingID,
        [string]$Title,
        [string]$Description,
        [array]$Materials,
        [bool]$Renew,
        [int]$ShippingTemplateID,
        [int]$ShopSectionID,
        [ValidateSet(
            'active',
            'inactive',
            'draft',
            IgnoreCase = $false
        )]
        [string]$State,
        [bool]$IsCustomizable,
        [float]$ItemWeight,
        [float]$ItemLength,
        [float]$ItemWidth,
        [float]$ItemHeight,
        [ValidateSet(
            'oz',
            'lb',
            'g',
            'kg',
            IgnoreCase = $false
        )]
        [string]$ItemWeightUnit,
        [ValidateSet(
            'in',
            'ft',
            'mm',
            'cm',
            'm',
            IgnoreCase = $false
        )]
        [string]$ItemDimensionsUnit,
        [bool]$NonTaxable,
        [int]$CategoryID,
        [int]$TaxonomyID,
        [array]$Tags,
        [ValidateSet(
            'i_did',
            'collective',
            'someone_else',
            IgnoreCase = $false
        )]
        [string]$WhoMade,
        [bool]$IsSupply,
        [ValidateSet(
            'made_to_order',
            '2010_2017',
            '2000_2009',
            '1998_1999',
            'before_1998',
            '1990_1997',
            '1980s',
            '1970s',
            '1960s',
            '1950s',
            '1940s',
            '1930s',
            '1920s',
            '1910s',
            '1900s',
            '1800s',
            '1700s',
            'before_1700',
            IgnoreCase = $false
        )]
        [string]$WhenMade,
        [ValidateSet(
            'men',
            'women',
            'unisex_adults',
            'teen_boys',
            'teen_girls',
            'teens',
            'boys',
            'girls',
            'children',
            'baby_boys',
            'baby_girls',
            'babies',
            'birds',
            'cats',
            'dogs',
            'pets',
            'not_specified',
            IgnoreCase = $false
        )]
        [string]$Recipient,
        [ValidateSet(
            'anniversary',
            'baptism',
            'bar_or_bat_mitzvah',
            'birthday',
            'canada_day',
            'chinese_new_year',
            'cinco_de_mayo',
            'confirmation',
            'christmas',
            'day_of_the_dead',
            'easter',
            'eid',
            'engagement',
            'fathers_day',
            'get_well',
            'graduation',
            'halloween',
            'hanukkah',
            'housewarming',
            'kwanzaa',
            'prom',
            'july_4th',
            'mothers_day',
            'new_baby',
            'new_years',
            'quinceanera',
            'retirement',
            'st_patricks_day',
            'sweet_16',
            'sympathy',
            'thanksgiving',
            'valentines',
            'wedding',
            IgnoreCase = $false
        )]
        [string]$Occasion,
        [array]$Style,
        [int]$ProcessingMin,
        [int]$ProcessingMax,
        [int]$FeaturedRank,
        [PSCredential]$ConsumerKey = $EtsyTokens.consumer_key,
        [PSCredential]$ConsumerSecret = $EtsyTokens.consumer_secret,
        [PSCredential]$Token = $EtsyTokens.oauth_token,
        [PSCredential]$TokenSecret = $EtsyTokens.oauth_token_secret
    )
    $splat = @{
        ConsumerKey = $ConsumerKey
        ConsumerSecret = $ConsumerSecret
        Token = $Token
        TokenSecret = $TokenSecret
        Uri = "https://openapi.etsy.com/v2/listings/$ListingID"
        Method = 'PUT'
        Parameters = @{}
    }

    switch ($PSBoundParameters.Keys) {
        'Title'	{$splat.Parameters.title = $Title}
        'Description' {$splat.Parameters.description = $Description}
        'Materials' {$splat.Parameters.materials = $Materials}
        'Renew' {$splat.Parameters.renew = $Renew}
        'ShippingTemplateID' {$splat.Parameters.shipping_template_id = $ShippingTemplateID}
        'ShopSectionID' {$splat.Parameters.shop_section_id = $ShopSectionID}
        'State' {$splat.Parameters.state = $State}
        'IsCustomizable' {$splat.Parameters.is_customizable = $IsCustomizable}
        'ItemWeight' {$splat.Parameters.item_weight = $ItemWeight}
        'ItemLength' {$splat.Parameters.item_length = $ItemLength}
        'ItemWidth' {$splat.Parameters.item_width = $ItemWidth}
        'ItemHeight' {$splat.Parameters.item_height = $ItemHeight}
        'ItemWeightUnit' {$splat.Parameters.item_weight_unit = $ItemWeightUnit}
        'ItemDimensionsUnit' {$splat.Parameters.item_dimensions_unit = $ItemDimensionsUnit}
        'NonTaxable' {$splat.Parameters.non_taxable = $NonTaxable}
        'CategoryID' {$splat.Parameters.category_id = $CategoryID}
        'TaxonomyID' {$splat.Parameters.taxonomy_id = $TaxonomyID}
        'Tags' {$splat.Parameters.tags = $Tags}
        'WhoMade' {$splat.Parameters.who_made = $WhoMade}
        'IsSupply' {$splat.Parameters.is_supply = $IsSupply}
        'When_made' {$splat.Parameters.when_made = $WhenMade}
        'Recipient' {$splat.Parameters.recipient = $Recipient}
        'Occasion' {$splat.Parameters.occasion = $Occasion}
        'Style' {$splat.Parameters.style = $Style}
        'ProcessingMin' {$splat.Parameters.processing_min = $ProcessingMin}
        'ProcessingMax' {$splat.Parameters.processing_max = $ProcessingMax}
        'FeaturedRank' {$splat.Parameters.featured_rank = $FeaturedRank}
    }
    if ($splat.Parameters.Count -eq 0) {
        Write-Error -Message "At least one listing attribute must be specified."
        return
    }

    Invoke-OAuthMethod @splat
}