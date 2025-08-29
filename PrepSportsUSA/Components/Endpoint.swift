//
//  Endpoint.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 26/11/2024.
//

struct Environment {
    static let login = "authenticate"
    static let userProfile = "users/%i"
    static let resetPassword = "users/request_reset_password"
    static let verifyCode = "verify_two_factor_authentication"
    static let resendAuthCode = "resend_two_factor_authentication"
    static let getStoriesWatcher = "users/%i/story_watchers/stories"
    static let getStoryWatcherPageView = "users/%i/story_watchers/pageviews"
    static let getStoryWatcherGeography = "users/%i/story_watchers/geographies"
    static let getStoryWatcherOrganization = "users/%i/story_watchers/organizations"
    static let getStoryWatcherOutlink = "users/%i/story_watchers/organizations"

    static let getIndexing = "/stories/%@/indexing_analytics"
    static let getGeography = "/stories/%@/geographies"
    static let getOutLinks = "/stories/%@/outlinks"
    static let getTopOrganizations = "/stories/%@/organizations"
    static let getStory = "/stories/%@"
    static let getPageView = "/stories/%@/pageviews"
  
    static let networks = "/networks"
    static let project = "/projects?network_id=%i"
    
    static let getProjectWatcher = "projects/%i/stories"
    static let getProjectGeography = "projects/%i/geographies"
    static let getProjectGeographyy = "projects/%@/geographies"

    static let getProjectOrganization = "projects/%i/organizations"
    static let getProjectOrganizationn = "projects/%@/organizations"

    static let getProjectOutlink = "projects/%i/outlinks"
    static let getProjectOutlinkk = "projects/%@/outlinks"
    static let getProjectPageView = "projects/%i/pageviews"
    
    static let searchStories = "stories/search"
    static let prePitches = "pre_pitches"
    static let prePitchMedia = "presign/pre_pitch_media"
    static let prePitchById = "pre_pitches/%i"
}
