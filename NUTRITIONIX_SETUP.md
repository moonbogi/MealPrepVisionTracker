# Nutritionix API Integration Guide

## Overview

The app now supports searching for ingredients using the **Nutritionix API**, which provides access to a comprehensive database of over 800,000 food items with detailed nutritional information.

## Features

✅ **Search Ingredients** - Search through Nutritionix's extensive food database  
✅ **Nutritional Details** - Get accurate nutritional information for ingredients  
✅ **Adjust Quantities** - Customize serving sizes before adding to pantry  
✅ **Multiple Units** - Support for various measurement units (cups, grams, oz, etc.)  
✅ **Smart Categorization** - Automatically categorize ingredients by type

## Getting API Keys

### Step 1: Sign Up for Nutritionix

1. Visit [https://developer.nutritionix.com/](https://developer.nutritionix.com/)
2. Click **"Sign Up"** or **"Get Your API Key"**
3. Create a free account (free tier includes 500 requests/day)
4. Verify your email address

### Step 2: Get Your API Credentials

1. Log into your Nutritionix Developer account
2. Go to your **Dashboard** or **API Keys** section
3. You'll receive two keys:
   - **Application ID** (App ID)
   - **Application Key** (App Key)
4. Copy both keys

### Step 3: Add Keys to the App

Open `MealPrepVisionTracker/Services/NutritionixService.swift` and replace the placeholder values:

```swift
// Line 83-85 in NutritionixService.swift
private let appId = "YOUR_APP_ID"      // Replace with your App ID
private let appKey = "YOUR_APP_KEY"    // Replace with your App Key
```

**Example:**
```swift
private let appId = "12345abcde"
private let appKey = "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
```

## How to Use

### Searching for Ingredients

1. Open the app and navigate to the **"My Pantry"** tab
2. Tap the **search icon (magnifying glass)** in the top-right corner
3. Type the ingredient name in the search bar (e.g., "chicken breast", "tomato", "olive oil")
4. Results will appear as you type (debounced for better performance)

### Adding Ingredients

1. Tap on any search result
2. The app will fetch detailed nutritional information
3. Review and adjust:
   - **Quantity** - Enter the amount you have
   - **Unit** - Select from dropdown (gram, cup, oz, etc.)
4. Tap **"Add to Pantry"** to save

### Search Features

- **Real-time search** with 0.5s debounce
- **Common foods** from Nutritionix database
- **Empty states** for no results or initial state
- **Loading indicators** during API calls
- **Error handling** for network issues

## API Limits

### Free Tier
- **500 requests per day**
- Access to common foods database
- Basic nutritional information

### Paid Tiers
For higher limits or branded food data, check [Nutritionix Pricing](https://www.nutritionix.com/business/api)

## Troubleshooting

### "Search Error" Alert

**Symptom:** Alert shows "Network error" or "API Error"

**Solutions:**
1. Check your API keys are correctly set
2. Verify internet connection
3. Ensure you haven't exceeded daily limit (500 requests)
4. Check Nutritionix API status at [status.nutritionix.com](https://status.nutritionix.com)

### No Results Found

**Symptom:** Search returns empty results

**Solutions:**
1. Try different search terms (e.g., "apple" instead of "apples")
2. Use common ingredient names
3. Check spelling
4. Try singular form of words

### Invalid API Keys

**Symptom:** Consistent API errors despite internet connection

**Solutions:**
1. Verify you copied the keys correctly (no extra spaces)
2. Check you're using both App ID and App Key (not just one)
3. Regenerate keys from Nutritionix dashboard
4. Ensure your account is verified

## Security Best Practices

### For Development

Currently, API keys are hardcoded in `NutritionixService.swift`. This is acceptable for:
- Personal projects
- Development/testing
- Apps not published to App Store

### For Production (App Store Release)

For production apps, consider:

1. **Store in Info.plist:**
   ```xml
   <key>NutritionixAppID</key>
   <string>YOUR_APP_ID</string>
   <key>NutritionixAppKey</key>
   <string>YOUR_APP_KEY</string>
   ```

2. **Read from configuration:**
   ```swift
   private let appId = Bundle.main.object(forInfoDictionaryKey: "NutritionixAppID") as? String ?? ""
   ```

3. **Use environment variables during build**

4. **Backend proxy** - Route API calls through your own server to hide keys

## Code Structure

### NutritionixService.swift
- `searchIngredients()` - Search for ingredients by name
- `getIngredientDetails()` - Get detailed nutritional info
- `convertToIngredient()` - Convert API response to app's Ingredient model

### IngredientSearchViewController.swift
- Search UI and results display
- Debounced search with 0.5s delay
- Empty states and loading indicators

### IngredientDetailViewController.swift
- Edit quantity and unit
- Preview ingredient before adding
- Save to Core Data

## API Response Examples

### Search Response
```json
{
  "common": [
    {
      "food_name": "chicken breast",
      "serving_unit": "breast",
      "serving_qty": 1,
      "photo": "https://..."
    }
  ]
}
```

### Nutrient Response
```json
{
  "foods": [
    {
      "food_name": "chicken breast",
      "serving_qty": 1,
      "serving_unit": "breast",
      "nf_calories": 231,
      "nf_protein": 43,
      "nf_total_fat": 5,
      "nf_total_carbohydrate": 0
    }
  ]
}
```

## Future Enhancements

Potential improvements for the Nutritionix integration:

- [ ] Display nutritional information in search results
- [ ] Show food photos from API
- [ ] Support branded foods search
- [ ] Add recent searches / favorites
- [ ] Barcode scanning for packaged foods
- [ ] Meal tracking integration with Nutritionix
- [ ] Recipe import from Nutritionix

## Resources

- [Nutritionix API Documentation](https://docs.nutritionix.com/v2/)
- [Nutritionix Developer Portal](https://developer.nutritionix.com/)
- [API Support](https://help.nutritionix.com/)

## Testing Without API Keys

If you want to test without signing up:

1. The app will show error messages but won't crash
2. You can still use the camera scanning feature
3. Manual ingredient addition still works
4. The search will just return empty results

## Summary

The Nutritionix integration adds powerful ingredient search capabilities to your meal prep app. With access to 800K+ foods and detailed nutritional data, users can quickly build their pantry without scanning every item.

**Next Steps:**
1. Sign up at [developer.nutritionix.com](https://developer.nutritionix.com/)
2. Get your API keys
3. Update `NutritionixService.swift` with your keys
4. Test the search feature
5. Enjoy comprehensive ingredient tracking!
