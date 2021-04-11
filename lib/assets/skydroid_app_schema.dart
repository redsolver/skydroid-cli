const skydroidAppSchema = {
    r"$id": "https://schema.skydroid.dev/v1/skydroid-app.schema.json",
    r"$schema": "http://json-schema.org/draft-06/schema#",
    "description": "A metadata definition for a SkyDroid app",
    "definitions": {
        "localized_data": {
            "type": "object",
            "properties": {
                "description": {
                    "type": "string"
                },
                "summary": {
                    "type": "string",
                    "maxLength": 120
                },
                "whatsNew": {
                    "type": "string"
                },
                "phoneScreenshotsBaseUrl": {
                    "type": "string",
                    "format": "uri"
                },
                "phoneScreenshots": {
                    "type": "array",
                    "items": {
                        "type": "string"
                    }
                }
            }
        }
    },
    "type": "object",
    "required": [
        "name",
        "authorName",
        "packageName",
        "icon"
    ],
    "properties": {
        "name": {
            "type": "string",
            "maxLength": 256
        },
        "authorName": {
            "type": "string",
            "maxLength": 256
        },
        "packageName": {
            "type": "string"
        },
        "icon": {
            "type": "string",
            "format": "uri"
        },
        "license": {
            "type": "string"
        },
        "categories": {
            "type": "array",
            "items": {
                "type": "string"
            }
        },
        "authorEmail": {
            "type": "string",
            "format": "email"
        },
        "sourceCode": {
            "type": "string",
            "format": "uri"
        },
        "issueTracker": {
            "type": "string",
            "format": "uri"
        },
        "changelog": {
            "type": "string",
            "format": "uri"
        },
        "localized": {
            "type": "object",
            "required": [
                "en-US"
            ],
            "propertyNames": {
                "pattern": r"^[a-z]{2}-[A-Z]{2}$"
            },
            "additionalProperties": {
                r"$ref": "#/definitions/localized_data"
            }
        }
    }
};
