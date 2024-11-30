//
//  PostHogService.swift
//  PersonaBot
//
//  Created by eth on 30/11/2024.
//

import PostHog

public class PostHogService {
    static let shared = PostHogService()

    public func Setup(){
        let config = PostHogConfig(apiKey: Config.POSTHOG_API_KEY, host: Config.POSTHOG_HOST)
        PostHogSDK.shared.setup(config)
    }
}