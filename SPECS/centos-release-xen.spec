Summary: CentOS Xen Support repo configs
Name: centos-release-xen
Epoch: 10
Version: 7
Release: 12%{?dist}
License: GPL
Group: System Environment/Base
# Include both so that the same srpm builds on both x86_64 and aarch64
Source1: CentOS-Xen.repo.x86_64
Source2: CentOS-Xen.repo.aarch64
Source4: grub-bootxen.sh
URL: http://wiki.centos.org/QaWiki/Xen4

Provides: centos-release-xen

BuildRoot: %{_tmppath}/centos-release-xen-root

ExclusiveArch: x86_64 aarch64

# This should pull in centos-release-virt-common
Requires: /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Virtualization

%description
yum Configs and some docs on the Xen stack included \in CentOS

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/etc
mkdir -p -m 755 $RPM_BUILD_ROOT/etc/yum.repos.d
mkdir -p $RPM_BUILD_ROOT/etc/sysconfig
mkdir -p -m 755 $RPM_BUILD_ROOT/%{_bindir}
%ifarch x86_64
install -m 644 %{SOURCE1} $RPM_BUILD_ROOT/etc/yum.repos.d/CentOS-Xen.repo
%endif
%ifarch aarch64
install -m 644 %{SOURCE2} $RPM_BUILD_ROOT/etc/yum.repos.d/CentOS-Xen.repo
%endif
install -m 744 %{SOURCE4} $RPM_BUILD_ROOT/%{_bindir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%config(noreplace) /etc/yum.repos.d/CentOS-Xen.repo
%{_bindir}/grub-bootxen.sh


%changelog
* Wed Jan 20 2016 George Dunlap <george.dunlap@citrix.com> - 7-12.centos
- Fix bug \in grub-bootxen.sh that caused no initrd line to be installed
  when installing or upgrading a kernel when xen was already installed

* Wed Nov 11 2015 George Dunlap <george.dunlap@citrix.com> - 7-11.centos
- buildlogs (centos-virt-xen-testing) packages are not signed

* Tue Nov  3 2015 George Dunlap <george.dunlap@citrix.com> - 7-10.centos
- Removed CBS repositories
- Moved C6 repos to Virt SIG layout
- Include all files so we can build the same srpm on any arch

* Wed Sep 16 2015 George Dunlap <george.dunlap@citrix.com> - 7-9.centos
- Add dependency on Virt SIG gpg key
- Shifted /etc/sysconfig/xen-kernel to xen package

* Tue Sep 15 2015 George Dunlap <george.dunlap@citrix.com> - 7-8.centos
- Configure for aarch64 systems

* Tue Sep 08 2015 George Dunlap <george.dunlap@citrix.com> - 7-7.centos
- Change virt6 repos to new format (virt6-xen-{44,46}-{testing,candidate})

* Tue Sep 01 2015 George Dunlap <george.dunlap@citrix.com> - 7-6.centos
- Add virt7-xen-46-* repos for 4.6 testing

* Thu Jul 30 2015 George Dunlap <george.dunlap@eu.citrix.com> - 7-5.centos
- Fix grub-bootxen.sh script

* Wed Jun 24 2015 George Dunlap <george.dunlap@eu.citrix.com> - 7-4.centos
- Update GPG key name
- Fix link following bug \in grub-bootxen

* Wed Jun 17 2015 George Dunlap <george.dunlap@eu.citrix.com> - 7-3.centos
- Update core C7 repos

* Tue May 26 2015 George Dunlap <george.dunlap@eu.citrix.com> - 7-2.el6.centos
- Use plain files rather than a tarball for easier source tracking
- Add Virt SIG repos (disabled by default)

* Mon Oct 20 2014 Johnny Hughes <johnny@centos.org> - 6-4.el6.centos
- shifted /etc/sysconfig/xen-kernel to centos-xen-release

* Thu Oct  9 2014 Johnny Hughes <johnny@centos.org> - 6-3.el6.centos
- Modified grub-bootxen.sh to allow for automatic grub updates for kernel install

* Wed Jun 19 2013 Karanbir Singh <kbsingh@centos.org> - 6-2.el6.centos
- Update to release

* Thu Jan 31 2013 Karanbir Singh <kbsingh@centos.org> - 6-0.el6.centos
- Build for CentOS Xen Beta release

