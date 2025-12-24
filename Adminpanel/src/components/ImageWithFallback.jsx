import { useState, useEffect } from 'react';
import './ImageWithFallback.css';

const ImageWithFallback = ({ 
  src, 
  alt, 
  className = '', 
  fallbackSrc = null,
  onError = null 
}) => {
  const [imgSrc, setImgSrc] = useState(src);
  const [hasError, setHasError] = useState(false);

  useEffect(() => {
    setImgSrc(src);
    setHasError(false);
  }, [src]);

  const defaultFallback = (
    <div className={`image-fallback ${className}`}>
      <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="12" cy="12" r="10" fill="#e5e7eb"/>
        <path d="M12 8v4m0 4h.01" stroke="#9ca3af" strokeWidth="2" strokeLinecap="round"/>
      </svg>
    </div>
  );

  const handleError = (e) => {
    if (!hasError) {
      setHasError(true);
      if (fallbackSrc) {
        setImgSrc(fallbackSrc);
        setHasError(false);
      } else if (onError) {
        onError(e);
      }
    }
  };

  if (!src) {
    return defaultFallback;
  }

  if (hasError && !fallbackSrc) {
    return defaultFallback;
  }

  return (
    <img
      src={imgSrc}
      alt={alt}
      className={className}
      onError={handleError}
      loading="lazy"
      crossOrigin="anonymous"
      referrerPolicy="no-referrer"
    />
  );
};

export default ImageWithFallback;

