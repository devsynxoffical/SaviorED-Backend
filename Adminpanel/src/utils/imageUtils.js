/**
 * Image utility functions for handling images with CORS and error handling
 */

/**
 * Check if image URL is valid and accessible
 */
export const isValidImageUrl = (url) => {
  if (!url) return false;
  try {
    const urlObj = new URL(url);
    return urlObj.protocol === 'http:' || urlObj.protocol === 'https:';
  } catch {
    return false;
  }
};

/**
 * Get image with proxy if CORS is an issue
 */
export const getImageUrl = (url, proxyUrl = null) => {
  if (!url) return null;
  
  // If proxy is provided, use it
  if (proxyUrl) {
    return `${proxyUrl}?url=${encodeURIComponent(url)}`;
  }
  
  return url;
};

/**
 * Create a data URL placeholder image
 */
export const createPlaceholderImage = (text = 'No Image', width = 300, height = 200) => {
  const svg = `
    <svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
      <rect width="100%" height="100%" fill="#f0f0f0"/>
      <text x="50%" y="50%" font-family="Arial" font-size="14" fill="#666" text-anchor="middle" dy=".3em">${text}</text>
    </svg>
  `.trim();
  
  return `data:image/svg+xml;base64,${btoa(svg)}`;
};

/**
 * Handle image load error with fallback
 */
export const handleImageError = (event, fallbackSrc = null) => {
  if (fallbackSrc) {
    event.target.src = fallbackSrc;
  } else {
    // Use placeholder
    event.target.src = createPlaceholderImage('Image not available');
  }
};

