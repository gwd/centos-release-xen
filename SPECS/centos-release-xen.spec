Summary: CentOS6 Xen Support repo configs
Name: centos-release-xen
Epoch: 10
Version: 7
Release: 1%{?dist}
License: GPL
Group: System Environment/Base
Source1: CentOS-Xen.repo.%{?rhel}
Source2: VirtSIG-Xen.repo.%{?rhel}
Source3: xen-kernel
Source4: grub-bootxen.sh
URL: http://wiki.centos.org/QaWiki/Xen4

Provides: centos-release-xen

BuildRoot: %{_tmppath}/centos-release-xen-root

%description
yum Configs and some docs on the Xen-4 stack included in CentOS-6 

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/etc
mkdir -p -m 755 $RPM_BUILD_ROOT/etc/yum.repos.d
mkdir -p $RPM_BUILD_ROOT/etc/sysconfig
mkdir -p -m 755 $RPM_BUILD_ROOT/%{_bindir}
install -m 644 %{SOURCE1} $RPM_BUILD_ROOT/etc/yum.repos.d/CentOS-Xen.repo
install -m 644 %{SOURCE2} $RPM_BUILD_ROOT/etc/yum.repos.d/VirtSIG-Xen.repo
install -m 644 %{SOURCE3} $RPM_BUILD_ROOT/etc/sysconfig/xen-kernel
install -m 744 %{SOURCE4} $RPM_BUILD_ROOT/%{_bindir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%config(noreplace) /etc/yum.repos.d/*
%{_bindir}/grub-bootxen.sh
%config(noreplace) /etc/sysconfig/xen-kernel


%changelog
* Tue May 26 2015 George Dunlap <george.dunlap@eu.citrix.com> - 7-1.el6.centos
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

