enum UserGroupStatus {
  notFound,    // User not found with the provided email
  available,   // User exists and is not in the group or invited
  invited,     // User exists and has been invited to the group
  inGroup      // User is already a member of the group
}