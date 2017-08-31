# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools multilib-minimal

if [[ ${PV} == *9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://git.xiph.org/opus.git"
else
	SRC_URI="https://github.com/xiph/opus/archive/v${PV/_/-}.tar.gz -> ${P}.tar.gz"
	if [[ "${PV}" != *_alpha* ]] &&  [[ "${PV}" != *_beta* ]] ; then
		KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd"
	fi
fi

DESCRIPTION="Open codec designed for internet transmission of interactive speech and audio"
HOMEPAGE="https://opus-codec.org/"

LICENSE="BSD-2"
SLOT="0"
INTRINSIC_FLAGS="cpu_flags_x86_sse cpu_flags_arm_neon"
IUSE="ambisonics custom-modes doc static-libs ${INTRINSIC_FLAGS}"

DEPEND="doc? ( app-doc/doxygen media-gfx/graphviz )"

S="${WORKDIR}/${P/_/-}"

src_prepare() {
	default

	if [[ ! -f package_version ]] ; then
		echo "PACKAGE_VERSION=\"${PV/_/-}\"" > package_version
	fi

	eautoreconf
}

multilib_src_configure() {
	local myeconfargs=(
		$(use_enable ambisonics)
		$(use_enable custom-modes)
		$(use_enable doc)
		$(use_enable static-libs static)
	)
	for i in ${INTRINSIC_FLAGS} ; do
		use ${i} && myeconfargs+=( --enable-intrinsics )
	done
	ECONF_SOURCE="${S}" \
	econf "${myeconfargs[@]}"
}
