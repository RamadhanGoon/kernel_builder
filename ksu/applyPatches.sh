#!/bin/bash
#
# hdjsjfjjwufbeizihfjejzf

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

# KernelSU-Next (ganti ke "next-susfs" kalau mau SUSFS)
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s next
git add . && git commit -am "drivers: KernelSU-Next"
KSU_git_ver=$(cd KernelSU-Next && git rev-list --count HEAD)
KSU_ver=$(($KSU_git_ver + 10200))

patchesdir="$outside/ksu/patches/$(echo $kernel_ver | cut -d. -f1,2)"
if [[ -d "$patchesdir" ]]; then
  for patch_file in "$patchesdir"/*.patch ; do
    git am "$patch_file" || { echo "patch failed: $patch_file"; git am --abort; exit 1; }
  done
  echo 'CONFIG_KSU=y' >> "${defconfig_file}"
else
  echo "patching ksu failed, the kernel version you want to patch doesnt have patches here yet"
  exit 1
fi

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-ksn${KSU_ver}\"/" "${defconfig_file}"

echo "$(grep 'CONFIG_LOCALVERSION=' ${defconfig_file})"

echo -e " \nincludes KernelSU-Next, ver ${KSU_ver}" >> banner_append
