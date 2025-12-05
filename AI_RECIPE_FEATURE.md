# AI Recipe Generation from Images

## Overview

Generate complete recipes from food photos! Upload any image of a dish (from Instagram, Pinterest, your camera, etc.) and the app will use AI to identify the ingredients and create a detailed recipe.

## Features

✅ **Photo Upload** - From camera or photo library  
✅ **AI Food Detection** - Uses Vision framework to identify food items  
✅ **Recipe Generation** - Creates complete recipes with:
- Recipe name and description
- Ingredient list with quantities
- Step-by-step instructions  
- Prep time and servings
- Cuisine type detection

✅ **Automatic Saving** - Generated recipes saved to your collection  
✅ **Fallback Mode** - Works without API keys (basic recipes)

## How It Works

### 1. Vision Framework Detection
- Analyzes image using Apple's Vision framework
- Identifies food items with confidence scores
- Filters for food-related items only

### 2. AI Recipe Generation (Optional)
- Uses OpenAI GPT-4 Vision API for advanced generation
- Creates detailed recipes based on visual analysis
- Provides accurate ingredient measurements

### 3. Fallback Mode
- If no API key configured, uses mock recipe generation
- Still creates usable recipes from detected items
- Great for testing without API costs

## Usage

### From Recipes Tab:

1. Tap the **photo icon** (📷) in top-right corner
2. Choose **"Photo Library"** or **"Take Photo"**
3. Select/capture an image of food
4. Tap **"Generate Recipe"**
5. Wait for AI analysis (10-30 seconds)
6. Review and **"Save Recipe"**

### Supported Image Sources:

- 📱 Screenshots from social media (Instagram, Pinterest, TikTok)
- 📷 Photos from your camera
- 🖼️ Downloaded food images
- 📖 Cookbook/recipe book photos

## Setup (Optional - For Best Results)

### OpenAI API (Recommended)

For the most accurate and detailed recipe generation:

1. **Get OpenAI API Key:**
   - Visit https://platform.openai.com/api-keys
   - Sign up or log in
   - Create a new API key
   - Pricing: ~$0.01-0.03 per image analysis

2. **Add to App:**
   - Open `RecipeAIService.swift`
   - Find line 31: `private let openAIKey = "YOUR_OPENAI_API_KEY"`
   - Replace with your key: `private let openAIKey = "sk-..."`

3. **You're Done!** The app will now use GPT-4 Vision for advanced recipe generation.

### Without API Key

The app works perfectly fine without an API key:

- ✅ Still detects food items using Vision framework
- ✅ Generates basic recipes automatically
- ✅ No cost, no signup required
- ⚠️ Less detailed than AI-powered generation

## Technical Details

### RecipeAIService.swift

**Main Methods:**
- `generateRecipeFromImage()` - Main entry point
- `detectFoodItems()` - Vision framework detection
- `generateRecipeWithAI()` - OpenAI API call
- `generateMockRecipe()` - Fallback recipe generation

**Models:**
- `DetectedRecipe` - Complete recipe structure
- `RecipeIngredient` - Individual ingredient
- `RecipeAIError` - Error handling

### RecipeFromImageViewController.swift

**UI Features:**
- Image preview with placeholder
- Photo/camera selection
- Loading indicators
- Status messages
- Recipe preview alert

**Image Sources:**
- PHPickerViewController (iOS 14+)
- UIImagePickerController (camera)
- Supports all image formats

## Examples

### Instagram Food Post
```
1. Screenshot a food post from Instagram
2. Upload to app
3. AI detects: pasta, tomatoes, basil, cheese
4. Generates: "Tomato Basil Pasta with Parmesan"
   - Ingredients with measurements
   - 6-step cooking instructions
   - Prep time: 25 minutes
```

### Pinterest Recipe Image
```
1. Save image from Pinterest
2. Upload to app  
3. AI sees: salmon, asparagus, lemon, herbs
4. Creates: "Herb-Crusted Salmon with Asparagus"
   - Detailed ingredient list
   - Cooking temperatures and times
   - Serves 2
```

### Your Own Photo
```
1. Take photo of meal at restaurant
2. Upload to app
3. AI identifies: chicken, rice, vegetables
4. Generates: "Chicken and Rice Bowl"
   - Approximate ingredients
   - Simple cooking steps
   - Servings estimate
```

## Error Handling

### Common Issues

**"No food items detected"**
- Image quality too low
- No recognizable food in image
- Try a clearer photo

**"AI processing failed"**
- API key not configured (falls back to basic mode)
- Network connectivity issue
- API rate limit reached

**"Invalid image"**
- Corrupted file
- Unsupported format
- Try different image

## Privacy & Data

- ✅ Images processed locally by Vision framework
- ✅ Only sent to OpenAI if API key configured
- ✅ No images stored on servers
- ✅ Generated recipes saved locally only

## API Costs (OpenAI)

**Pricing Estimates:**
- GPT-4 Vision: ~$0.01-0.03 per image
- 100 recipes: ~$1-3
- First $5 credit often free for new accounts

**Tips to Reduce Costs:**
- Use mock mode for testing
- Only use AI for important recipes
- Compress images before upload

## Future Enhancements

Potential improvements:

- [ ] Support video analysis
- [ ] Batch processing multiple images
- [ ] Recipe refinement/editing
- [ ] Nutritional information calculation
- [ ] Allergen detection
- [ ] Cooking difficulty rating
- [ ] Shopping list generation
- [ ] Similar recipe suggestions

## Troubleshooting

### App crashes on image selection
- Check photo library permissions in Settings
- Update to latest iOS version
- Restart app

### Slow processing
- Large image files (compress first)
- Slow network connection
- API server latency

### Inaccurate recipes
- Poor image quality
- Multiple dishes in one image
- Try using OpenAI API for better results

## Code Structure

```
Services/
  RecipeAIService.swift       // AI logic & API calls
  
ViewControllers/
  RecipeFromImageViewController.swift  // UI & image handling
  RecipesViewController.swift  // Integration (delegate)

Models/
  DetectedRecipe              // AI-generated recipe model
  RecipeIngredient            // Ingredient with quantity
```

## Summary

This feature transforms the app from just tracking ingredients to actually helping users discover and create recipes. By leveraging both Apple's Vision framework and optional OpenAI integration, users can:

1. **Find inspiration** - Turn any food photo into a recipe
2. **Learn cooking** - Get step-by-step instructions
3. **Save favorites** - Build personal recipe collection
4. **No barriers** - Works without API keys (basic mode)

**Perfect for:**
- Social media food enthusiasts
- Home cooks learning new dishes
- Meal preppers planning weekly menus
- Anyone who sees food and thinks "I want to make that!"

---

**Ready to use!** Just tap the camera icon in the Recipes tab and start generating recipes from images! 📸🍳
