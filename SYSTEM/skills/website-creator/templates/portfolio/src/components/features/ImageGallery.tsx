"use client";

import { useState } from "react";
import { Lightbox } from "@/components/ui/Lightbox";
import { cn } from "@/lib/utils";

interface Image {
  src: string;
  alt: string;
  caption?: string;
}

interface ImageGalleryProps {
  images: Image[];
  columns?: 2 | 3 | 4;
  className?: string;
}

export function ImageGallery({
  images,
  columns = 3,
  className,
}: ImageGalleryProps) {
  const [lightboxOpen, setLightboxOpen] = useState(false);
  const [currentIndex, setCurrentIndex] = useState(0);

  const openLightbox = (index: number) => {
    setCurrentIndex(index);
    setLightboxOpen(true);
  };

  return (
    <>
      <div
        className={cn(
          "grid gap-4",
          columns === 2 && "grid-cols-2",
          columns === 3 && "grid-cols-2 md:grid-cols-3",
          columns === 4 && "grid-cols-2 md:grid-cols-4",
          className
        )}
      >
        {images.map((image, index) => (
          <button
            key={index}
            className="relative aspect-square overflow-hidden rounded-lg group"
            onClick={() => openLightbox(index)}
          >
            <img
              src={image.src}
              alt={image.alt}
              className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-110"
            />
            {image.caption && (
              <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex items-end p-4">
                <p className="text-white text-sm">{image.caption}</p>
              </div>
            )}
          </button>
        ))}
      </div>

      <Lightbox
        isOpen={lightboxOpen}
        onClose={() => setLightboxOpen(false)}
        images={images}
        currentIndex={currentIndex}
        onNavigate={setCurrentIndex}
      />
    </>
  );
}