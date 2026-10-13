build/flex.zip: src/__init__.py src/blender_manifest.toml
	mkdir -p build
	python3 -m zipfile -c $@ $^

.PHONY: clean
clean:
	rm -rf build
