# Database Specification

Initial entities:

- User
- Family
- FamilyMember
- FamilyInvitation
- Task
- TaskAssignee
- RecurrenceRule
- TaskReminder
- TaskAttachment
- ShoppingList
- ShoppingItem
- ShoppingCategory
- Product
- RecurringShoppingItem
- Notification
- TimelineEvent
- CalendarConnection

All shared records are isolated by `family_id`.
Private records are readable only by `owner_user_id`, including from admins.
