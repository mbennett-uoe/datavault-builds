<#import "*/layout/defaultlayout.ftl" as layout>
<#-- Specify which navbar element should be flagged as active -->
<#global nav="admin">
<@layout.vaultLayout>
    <#import "/spring.ftl" as spring />

<div class="container">

    <ol class="breadcrumb">
        <li><a href="${springMacroRequestContext.getContextPath()}/admin/"><b>Administration</b></a></li>
        <li><a href="${springMacroRequestContext.getContextPath()}/admin/vaults"><b>Reviews</b></a></li>
        <li class="active"><b>Vault:</b> ${vault.name?html}</li>
    </ol>

    <form id="create-review" action="${springMacroRequestContext.getContextPath()}/admin/vaults/${vault.getID()}/reviews/${currentReview.getId()}" method="post">

    <div class="bs-callout">
        <h2>
            <span class="glyphicon glyphicon-folder-close"></span> ${vault.name?html}
        </h2>
        <h2>
            <small>
                ${vault.description?html}
            </small>
        </h2>
        <hr>
        <p>
            <b>Owner:</b> ${vault.userID?html}<br/>
            <b>Dataset name:</b> ${vault.datasetName?html}<br/>
            <b>Created:</b> ${vault.creationTime?datetime}<br/>
            <b>Group:</b> ${group.name?html}<br/>
            <b>Retention Policy:</b> ${retentionPolicy.name?html}<br/>
            <b>Retention Policy expiry date:</b> ${vault.policyExpiry?datetime} (Status: ${vault.policyStatusStr?html})<br/>
            <b>Size:</b> ${vault.getSizeStr()}<br/>
        </p>

        <p>
            <b>Current review date:</b> ${vault.reviewDate?datetime}</b>
        </p>

        <#if error?has_content>
            <div class="alert alert-danger" role="alert">
                ${error}
            </div>
        </#if>

        <div class="form-group">
            <label class="control-label">New Review Date</label>
            <@spring.bind "vaultReviewModel.newReviewDate"/>
            <input type="text" class="form-control" id="newReviewDate" name="${spring.status.expression}" value='${spring.status.value!""}'/>
        </div>

        <div class="form-group">
            <label class="control-label">Comment</label>
            <@spring.bind "vaultReviewModel.comment" />
            <input type="text" class="form-control" name="${spring.status.expression}" value="${spring.status.value!""}"/>
        </div>

        <#if drml.depositReviewModels?has_content>

            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr class="tr">
                            <th>Deposit</th>
                            <th>Status</th>
                            <th>Timestamp</th>
                            <th>Delete</th>
                            <th>Comment</th>
                        </tr>
                    </thead>

                    <tbody>
                        <#list drml.depositReviewModels as drm>

                            <input type="hidden" name="depositReviewModels[${drm_index}].depositId" value="${drm.getDepositId()}">
                            <input type="hidden" name="depositReviewModels[${drm_index}].depositReviewId" value="${drm.getDepositReviewId()}">

                            <tr class="tr">
                                <td>
                                    <a href="${springMacroRequestContext.getContextPath()}/vaults/${vault.getID()}/deposits/${drm.depositId}">${drm.name?html}</a>
                                </td>

                                <td>
                                    <div id="deposit-status" class="job-status">
                                        <#if drm.statusName == "COMPLETE">
                                            <div class="text-success">
                                                <span class="glyphicon glyphicon-ok" aria-hidden="true"></span>&nbsp;Complete
                                            </div>
                                        <#elseif drm.statusName == "FAILED">
                                            <div class="text-danger">
                                                <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>&nbsp;Failed
                                            </div>
                                        <#elseif drm.statusName == "NOT_STARTED">&nbsp;Queued
                                        <#elseif drm.statusName == "IN_PROGRESS">
                                            <span class="glyphicon glyphicon-refresh glyphicon-refresh-animate"></span>&nbsp;In progress
                                        <#else>
                                            ${drm.statusName}
                                        </#if>
                                    </div>
                                </td>

                                <td> ${drm.getCreationTime()?datetime}</td>

                                <td>
                                    <div class="form-check">
                                    <!--<div class="custom-control custom-checkbox">-->
                                        <@spring.bind "drml.depositReviewModels[${drm_index}].toBeDeleted" />
                                        <input type="checkbox" class="form-check-input" id="deleteDeposit"
                                               name="${spring.status.expression}"
                                               value="true" ${drm.toBeDeleted?then('checked', '')} />
                                    </div>
                                </td>

                                <td>
                                <div class="form-group">
                                    <@spring.bind "drml.depositReviewModels[${drm_index}].comment" />
                                    <input type="text"
                                           class="form-control"
                                           name="${spring.status.expression}"
                                           value="${spring.status.value!""}"/>
                                </div>
                                </td>

                            </tr>
                        </#list>
                    </tbody>
                </table>
            </div>
            <#else>
               <p>No deposits</p>
         </#if>

         </div>

        <div class="form-group">
            <input type="submit" name="action" value="Save" class="btn btn-info" />
            <br>Save the entered data but without completing the Review.</br>
        </div>
        <div class="form-group">
            <input type="submit" name="action" value="Submit" class="btn btn-success" />
            <br>Save the entered data and complete the Review. Selected deposits will be deleted.</br>
        </div>
        <div class="form-group">
            <input type="submit" name="action" value="Cancel" class="btn btn-danger" />
        </div>


        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
    </form>

</div>

<script>
    $(document).ready(function () {

        $.datepicker.setDefaults({
            dateFormat: "yy-mm-dd",
            changeMonth: true,
            changeYear: true,
            showOtherMonths: true,
            selectOtherMonths: true
        });

        $( "#newReviewDate" ).datepicker({
            minDate: '+1m'
        });

        $.validator.addMethod(
                "date",
                function(value, element) {
                    // put your own logic here, this is just a (crappy) example

                    if (value){
                        return value.match(/^((1|2)\d\d\d)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$/);
                    } else {
                        return true;
                    }
                },
                "Please enter a valid date in YYYY-MM-DD format."
        );
        $.validator.addMethod(
                "newReviewDate",
                function(value, element) {
                    // put your own logic here, this is just a (crappy) example

                    if (value){
                        var inAMonth = new Date();
                        inAMonth.setMonth(inAMonth.getMonth() + 1);
                        inAMonth.setHours( 0,0,0,0 );

                        var selectedDate = new Date(value);

                        return selectedDate >= inAMonth;
                    } else {
                        return true;
                    }
                },
                "The review date must be at least one month in the future. The review date is the date at which a decision may be made about potentially deleting the data. If you believe you need the review date to be sooner, please contact the support team using the Contact button at the top of the page."
        );

        $('button[type="submit"]').on("click", function() {
            $('#submitAction').val($(this).attr('value'));
        });

        $('#create-review').validate({
            debug: true,
            rules: {
                newReviewDate : {
                    date: true,
                    newReviewDate: true
                }
            },
            highlight: function (element) {
                $(element).closest('.form-group').removeClass('has-success').addClass('has-error');
            },
            success: function (element) {
                element.addClass('valid')
                        .closest('.form-group').removeClass('has-error').addClass('has-success');
            },
            submitHandler: function (form) {
                $('button[type="submit"]').prop('disabled', true);
                form.submit();
            }
        });

        $('[data-toggle="tooltip"]').tooltip({
            'placement': 'right'
        });
    }); $('[data-toggle="popover"]').popover();
</script>

</@layout.vaultLayout>
