//
//  Supabase.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//

import Foundation
import Supabase

// https://supabase.com/docs/guides/getting-started/tutorials/with-swift
let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://caevfrlaqsgjrbkyhizp.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNhZXZmcmxhcXNnanJia3loaXpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI3OTYxNzQsImV4cCI6MjA0ODM3MjE3NH0.fKMfNlN1kONrlgunhWPXluU-fNEFC6V-Eom2pGysaK8"
)
