@/**************************************************************************/
@/*                                                                        */
@/*       Copyright (c) Microsoft Corporation. All rights reserved.        */
@/*                                                                        */
@/*       This software is licensed under the Microsoft Software License   */
@/*       Terms for Microsoft Azure RTOS. Full text of the license can be  */
@/*       found in the LICENSE file at https://aka.ms/AzureRTOS_EULA       */
@/*       and in the root directory of this software.                      */
@/*                                                                        */
@/**************************************************************************/
@
@
@/**************************************************************************/
@/**************************************************************************/
@/**                                                                       */
@/** ThreadX Component                                                     */
@/**                                                                       */
@/**   Thread                                                              */
@/**                                                                       */
@/**************************************************************************/
@/**************************************************************************/
@
@
    .text
    .align 4
    .syntax unified
@/**************************************************************************/
@/*                                                                        */
@/*  FUNCTION                                               RELEASE        */
@/*                                                                        */
@/*    _tx_thread_context_save                           Cortex-M7/GNU     */
@/*                                                           6.1          */
@/*  AUTHOR                                                                */
@/*                                                                        */
@/*    William E. Lamie, Microsoft Corporation                             */
@/*                                                                        */
@/*  DESCRIPTION                                                           */
@/*                                                                        */
@/*    This function is only needed for legacy applications and it should  */
@/*    not be called in any new development on a Cortex-M.                 */
@/*    This function saves the context of an executing thread in the       */
@/*    beginning of interrupt processing.  The function also ensures that  */
@/*    the system stack is used upon return to the calling ISR.            */
@/*                                                                        */
@/*  INPUT                                                                 */
@/*                                                                        */
@/*    None                                                                */
@/*                                                                        */
@/*  OUTPUT                                                                */
@/*                                                                        */
@/*    None                                                                */
@/*                                                                        */
@/*  CALLS                                                                 */
@/*                                                                        */
@/*    None                                                                */
@/*                                                                        */
@/*  CALLED BY                                                             */
@/*                                                                        */
@/*    ISRs                                                                */
@/*                                                                        */
@/*  RELEASE HISTORY                                                       */
@/*                                                                        */
@/*    DATE              NAME                      DESCRIPTION             */
@/*                                                                        */
@/*  05-19-2020     William E. Lamie         Initial Version 6.0           */
@/*  09-30-2020     William E. Lamie         Modified comment(s),          */
@/*                                            resulting in version 6.1    */        
@/*                                                                        */
@/**************************************************************************/
@VOID   _tx_thread_context_save(VOID)
@{
    .global  _tx_thread_context_save
    .thumb_func
_tx_thread_context_save:
@
@ /* Not needed for this port - just return!  */
    BX      lr
@}
