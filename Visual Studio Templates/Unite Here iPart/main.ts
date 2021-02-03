module $fileinputname$Module {
    export class $fileinputname$Controller extends SecurityBsiBase {

        /**
         * Id of the controller
         */
        public static id = "$fileinputname$Controller";
     
        /**
         * This allows the controller to support dependency injection
         * after minification
         */
        public static $inject = [
            app.core.Services.IPartSettingsService.id,
            "validationService",
            "securityService",
            "getUrlParameterService",
            "$attrs",
            "$q",
            "$rootScope"
        ];

        /**
         * Constructor
         * 
         * @param settingsService Contains ipart settings
         * @param validationService Validation service allows multiple iParts to share validation context
         * @param securityService Used to lock down the ipart based on role settings
         * @param getUrlParameterService Service for accessing URL parameters
         * @param $attrs This can be used to pass attributes to a directive
         * @param $q Angular q service for managing multiple promises
         * @param $rootScope Every application has a single root scope. All other scopes are descendant scopes of the root scope
         */
        constructor(public readonly settingsService: IIpartSettingsService,
            public readonly validationService: IValidationService,
            public readonly securityService: ISecurityService,
            public readonly getUrlParameterService: IGetUrlParameterService,
            public readonly $attrs: ng.IAttributes,
            public readonly $q: ng.IQService,
            public readonly $rootScope: ng.IRootScopeService) {

            super(settingsService, $attrs, $q, securityService, $rootScope, validationService, getUrlParameterService);

            console.debug(`${$fileinputname$Controller.id} ctor()`);
        }

        /**
         * This is called after the page has finished loading
         */
        public init(): void {
            console.debug(`${$fileinputname$Controller.id} init()`);
        }
    }

    console.debug(`Registering ${$fileinputname$Controller.id} ipart controller`);
    // register the controller with app
    angular
        .module("BsiModule")
        .controller($fileinputname$Controller.id, $fileinputname$Controller)
        .config([
            "$compileProvider",
            "$provide",
            ($compileProvider, $provide) => {
                $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|chrome-extension|webcal):/);
                $provide.decorator("$locale",
                    [
                        "$delegate", $delegate => {
                            if ($delegate.id === "en-us") {
                                $delegate.NUMBER_FORMATS.PATTERNS[1].negPre = "-";
                                $delegate.NUMBER_FORMATS.PATTERNS[1].posPre = "";
                            }
                            return $delegate;
                        }
                    ]);
            }
        ]);
}