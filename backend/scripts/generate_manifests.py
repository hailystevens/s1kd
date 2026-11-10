from app.settings import settings
from app.xml_pipeline import compile_release


if __name__ == "__main__":
    compile_release(settings.source_dir, settings.data_dir, release_id="initial")
    print("Generated release and manifest artifacts.")
