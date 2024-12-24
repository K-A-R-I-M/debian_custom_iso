all: build_custom_debian_iso_with_podman

build_custom_debian_iso_with_podman:
	podman build -t debian_pull_modify_iso .
	podman run --privileged --name=builder_debianiso debian_pull_modify_iso
	podman cp builder_debianiso:/work/debian_iso_custom/debian_latest_custom_KARIM.iso ./
	podman rm -f builder_debianiso
	podman rmi -f debian_pull_modify_iso