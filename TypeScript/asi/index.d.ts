declare var gWebRoot: string;
declare var gWebSiteRoot: string;
declare var GetRadWindowManager: any;

declare module app {
    export var core: any;
}

interface IClientSideContentItem {
    Settings: any;
}

interface IIpartSettingsService {
    getSettings(contentKey: string, contentItemKey: string);
}

interface Value2 {
    $type: string;
    Name: string;
    Value: string;
}

interface Properties {
    $type: string;
    $values: Value2[];
}

interface Value {
    $type: string;
    EntityTypeName: string;
    Properties: Properties;
}

interface Items {
    $type: string;
    $values: Value[];
}

interface SyncRoot {
    $type: string;
}

interface GenericEntityData {
    $type: string;
    Items: Items;
    Offset: number;
    Limit: number;
    Count: number;
    SyncRoot: SyncRoot;
    IsSynchronized: boolean;
    TotalCount: number;
    NextPageLink?: any;
    HasNext: boolean;
    NextOffset: number;
}


