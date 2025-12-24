package com.example.pl_image_downloader.models.enum

/**
 * MimTypes
 * An enumeration of common MIME types for image files.
 */
enum class MimeTypes(type: String) {
    IMAGE_JPEG("image/jpeg"),
    IMAGE_PNG("image/png"),
    IMAGE_GIF("image/gif"),
    IMAGE_SVG_XML("image/svg+xml"),
    IMAGE_BMP("image/bmp");

    val typeName = type

    companion object {
        fun fromValue(name: String): MimeTypes {
            return entries.firstOrNull { it.typeName.equals(name, ignoreCase = true) }
                ?: throw Exception("Mime type not found: $name")
        }
    }
}