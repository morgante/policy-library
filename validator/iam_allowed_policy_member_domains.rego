#
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package templates.gcp.GCPIAMAllowedPolicyMemberDomainsConstraint

import data.validator.gcp.lib as lib

# If a primary domain is whitelisted, all of its sub domains are whitelisted as well.
deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	lib.get_constraint_params(constraint, params)
	asset := input.asset
	iam_policy := asset.iam_policy
	unique_members := {m | m = iam_policy.bindings[_].members[_]}
	member := unique_members[_]
	matched_domains := [m | m = member; re_match(sprintf("[@.]%v$", [params.domains[_]]), member)]
	count(matched_domains) == 0

	message := sprintf("IAM policy for %v contains member from unexpected domain: %v", [asset.name, member])

	metadata := {"member": member}
}