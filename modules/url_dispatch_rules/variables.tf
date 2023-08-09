variable "project_id" {
  description = "The project in which to create the dispatch rules."
  type        = string
}

variable "dispatch_rules" {
  description = "The dispatch rules to create in this GAE app."
  type        = list(map(string))
}
