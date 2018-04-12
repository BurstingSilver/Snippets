const config = {
		attachTo: angular.element(document.body),
		controller: PanelShellController,
		controllerAs: "vm",
		locals: {
			onClose: (mdPanelRef: any) => {
				const panelScope = mdPanelRef.config.scope.vm as PanelShellController;             
			}
		},
		disableParentScroll: true,
		templateUrl: `${gWebRoot}/Custom/Templates/mdPanelTemplate.html`,
		hasBackdrop: true,
		zIndex: 50,
		position: this.$mdPanel.newPanelPosition().absolute().center(),
		panelClass: "bsi-panel",
		clickOutsideToClose: false,
		escapeToClose: false,
		onDomAdded: () => {
			angular.element("body").css("top", "unset");
		}
	} as ng.material.IPanelConfig;

this.$mdPanel.open(config).then((mdPanelRef: any) => {
    const panelScope = mdPanelRef.config.scope.vm as PanelShellController;
    panelScope.init();
});