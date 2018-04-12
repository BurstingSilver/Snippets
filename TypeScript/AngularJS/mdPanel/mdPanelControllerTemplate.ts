module Shell {
    /**
     * This service contains all buisness logic for the select payment dialog
     */
    export class PanelShellController  {
        
        /**
         * This allows the controller to support dependency injection
         * after minification
         */
        public static $inject = [
            "mdPanelRef",
            "alertService",
            "onClose"
        ];

        /**
         * Constructor
         *
         * @param mdPanelRef A reference to a created panel. This reference contains a unique id for the panel, along with the following properties
         * @param alertService This service is used to display alerts to the user
         * @param onClose this is used to trigger the onClose event so we can perform logic after the popup has been closed
         */
        constructor(private readonly mdPanelRef: ng.material.IPanelRef,        
            private readonly alertService: IAlertService,
            private readonly onClose: Function) {
        }

        /**
         * Called when the dialog is ready
         */
        public init(): void {
            console.debug("PanelShellController loaded.");
        }

        /**
         * Closes the dialog
         */
        private close(): void {
            this.mdPanelRef.close().then((mdPanelRef: ng.material.IPanelRef) => {
                this.onClose(mdPanelRef);
                this.mdPanelRef.destroy();
            });
        }

        /**
         * Cancels the dialog
         */
        private cancel(): void {
            this.mdPanelRef.close().then(() => {
                this.mdPanelRef.destroy();
            });
        }
    }
}