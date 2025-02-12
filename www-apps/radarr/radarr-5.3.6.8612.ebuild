# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

SRC_URI="
	amd64? (
		elibc_glibc? ( https://github.com/Radarr/Radarr/releases/download/v${PV}/Radarr.master.${PV}.linux-core-x64.tar.gz )
		elibc_musl? ( https://github.com/Radarr/Radarr/releases/download/v${PV}/Radarr.master.${PV}.linux-musl-core-x64.tar.gz )
	)
	arm? (
		elibc_glibc? ( https://github.com/Radarr/Radarr/releases/download/v${PV}/Radarr.master.${PV}.linux-core-arm.tar.gz )
		elibc_musl? ( https://github.com/Radarr/Radarr/releases/download/v${PV}/Radarr.master.${PV}.linux-musl-core-arm.tar.gz )
	)
	arm64? (
		elibc_glibc? ( https://github.com/Radarr/Radarr/releases/download/v${PV}/Radarr.master.${PV}.linux-core-arm64.tar.gz )
		elibc_musl? ( https://github.com/Radarr/Radarr/releases/download/v${PV}/Radarr.master.${PV}.linux-musl-core-arm64.tar.gz )
	)
"

DESCRIPTION="A fork of Sonarr to work with movies a la Couchpotato"
HOMEPAGE="https://www.radarr.video"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist strip test"

RDEPEND="
	acct-group/radarr
	acct-user/radarr
	media-video/mediainfo
	dev-libs/icu
	dev-util/lttng-ust:0
	dev-db/sqlite
	sys-libs/glibc
"

QA_PREBUILT="*"

S="${WORKDIR}/Radarr"

src_prepare() {
	default

	# https://github.com/dotnet/runtime/issues/57784
	rm libcoreclrtraceptprovider.so Radarr.Update/libcoreclrtraceptprovider.so || die
}

src_install() {
	newinitd "${FILESDIR}/${PN}.init" ${PN}

	keepdir /var/lib/${PN}
	fowners -R ${PN}:${PN} /var/lib/${PN}

	insinto /etc/logrotate.d
	insopts -m0644 -o root -g root
	newins "${FILESDIR}/${PN}.logrotate" ${PN}

	dodir  "/opt/${PN}"
	cp -R "${S}/." "${D}/opt/radarr" || die "Install failed!"

	systemd_dounit "${FILESDIR}/radarr.service"
	systemd_newunit "${FILESDIR}/radarr.service" "${PN}@.service"
}
