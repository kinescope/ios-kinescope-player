//
//  KinescopeVideoListResponse.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

public struct KinescopeVideoListResponse: Codable {

    public let meta: KinescopeMetaData?
    public let data: [KinescopeVideo]

}
